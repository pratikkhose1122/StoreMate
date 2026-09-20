# API Contracts Document — StoreMate

| Field        | Value                                              |
|--------------|----------------------------------------------------|
| Version      | 1.2                                                |
| Status       | Locked                                             |
| Owner        | Pratik Khose                                       |
| Last Updated | 2026-09-09                                         |
| Audience     | Backend Engineers, Flutter Engineers               |
| Dependencies | 03-System-Architecture.md, 04-Database-Design.md   |

> [!IMPORTANT]
> This document defines the strict Remote Procedure Call (RPC) interfaces exposed by Supabase. Because StoreMate adheres to the "RPC-only Writes" rule, Flutter never performs direct `INSERT`, `UPDATE`, or `DELETE` operations. All writes must route through these defined RPCs.

---

## 1. Global RPC Envelopes & Evolution

To guarantee forward compatibility, diagnostic capability, and simplified Flutter repository parsing, all RPCs must conform to standardized request and response envelopes.

### 1.1 Mandatory Request Metadata (The Envelope)
Every modifying RPC must accept a JSON envelope containing the business payload, optimistic concurrency parameters, and diagnostic metadata.

```json
{
  "p_intent_id": "uuid",
  "p_client_id": "uuid",
  "p_device_id": "uuid",
  "p_app_version": "text",
  "p_schema_version": 3,
  "p_business_timestamp": "timestamptz",
  "p_expected_version": 1, // Only required for mutable entities
  "p_payload": {} // The actual business payload
}
```
**Versioning Rule:** `p_expected_version` is **only** required for RPCs updating mutable Master Data entities (products, customers, settings, categories, staff). It is omitted for append-only operations (sales, refunds, payments, inventory ledger).

### 1.2 API Evolution Policy
As parameters change over time, the API must not break older clients:
- New parameters must be strictly `OPTIONAL` with safe defaults.
- Existing parameter semantics cannot change in-place.
- Breaking changes require a new RPC endpoint (e.g., `rpc_process_sale_v2`).
- If a client sends an unsupported `p_schema_version`, the RPC must reject it with a `SCHEMA_UNSUPPORTED` error, forcing the app to update.

### 1.3 Standardized Success Response
```json
{
  "success": true,
  "entity_id": "uuid",
  "version": 3,
  "server_timestamp": "timestamptz",
  "response_payload": {} 
}
```

### 1.4 Standard Error Namespace & Retry Matrix
Errors must return structured JSON utilizing a stable, symbolic code namespace (independent of HTTP status codes).
```json
{
  "code": "VERSION_CONFLICT",
  "message": "This product was modified on another device.",
  "field": "p_expected_version",
  "retryable": false
}
```

**Sync Worker Retry Classification Matrix:**
| Error Source | Code Example | Retryable | Worker Action |
| --- | --- | --- | --- |
| **Transport / Network** | `TLS_FAILURE`, `DNS_FAILURE`, `SOCKET_TIMEOUT` | **Yes** | Exponential backoff. |
| **Database Transient**| `DB_DEADLOCK`, `GATEWAY_TIMEOUT` | **Yes** | Exponential backoff. |
| **Validation** | `VALIDATION_FAILED`, `BARCODE_EXISTS` | **No** | Move to Dead Letter Queue. |
| **Authorization** | `PERMISSION_DENIED` | **No** | Alert user, pause queue. |
| **Concurrency** | `VERSION_CONFLICT` | **No** | Move to DLQ, trigger server pull. |
| **Amnesia** | `INTENT_STALE` | **No** | Discard intent completely. |

---

## 2. RPC Transaction Architecture

### 2.1 The Canonical Execution Order
Every financial RPC must execute exactly in this order inside a strict `BEGIN ... COMMIT` block. If any step fails, `ROLLBACK` executes instantly.

```text
BEGIN
  $\downarrow$
1. Authorization (Resolve active shop, user role, verify permissions)
  $\downarrow$
2. Idempotency (Check intent_log. If exists $\rightarrow$ return cached payload & EXIT)
  $\downarrow$
3. Concurrency (Check p_expected_version == current version for Master Data)
  $\downarrow$
4. Validation (RPC provides friendly errors; DB constraints act as final safeguard)
  $\downarrow$
5. Mutations (Insert/Update ledgers)
  $\downarrow$
6. Audit (Insert into audit_log for Master Data only)
  $\downarrow$
7. Cache (Store response_payload into intent_log)
  $\downarrow$
COMMIT
```

### 2.2 Validation Ownership
- **RPC Validation:** Handles complex business logic and returns user-friendly, structured error strings (e.g., "Discount exceeds subtotal").
- **Database Constraints:** Serve as the silent, unyielding final safeguard. If both validate the same rule, the RPC must catch it first.

### 2.3 Idempotency & 30-Day Amnesia Rule
If a client attempts to sync an `intent_id` where `p_business_timestamp` is older than 30 days, the RPC **must reject** the sync with `INTENT_STALE`. This prevents duplicate replay amnesia since the server's `intent_log` purges after 30 days.

---

## 3. Operational Subsystems

### 3.1 Invoice Sequence Contract
Invoices require gapless sequential numbering (`INV-YYYY-######`) that resets yearly.
- **Concurrency Locking:** The `rpc_process_sale` function must acquire a row-level lock (`SELECT ... FOR UPDATE`) on the `invoice_sequences` table.
- **Timezone Dependency:** The `current_year` is determined by converting the `p_business_timestamp` into the specific `timezone` stored on the `shops` table.
- **Gap Handling:** Because it executes inside the atomic transaction, if the sale rolls back, the sequence increment rolls back, preventing gaps.

### 3.2 Audit Contract
The `audit_log` is explicitly reserved for **Master Data and Settings**. High-volume ledgers (Sales, Refunds, Payments, Inventory Ledger) are intrinsically immutable and act as their own audit trails. Duplicating them into `audit_log` is forbidden.

### 3.3 Bulk RPC Atomicity
To reduce network roundtrips during sync, specific endpoints support bulk arrays:
- **Bulk Financials (`rpc_bulk_adjust_inventory`):** **Option A (All-or-Nothing).** The entire array executes in one transaction. If one fails, 0 are inserted.
- **Bulk Imports (`rpc_bulk_import_products`):** **Option B (Partial Success).** Allows valid rows to succeed while returning an array of specific item errors for the UI to handle.

### 3.4 Read Contracts & PostgREST Consistency
To reduce backend bottlenecks, StoreMate uses Supabase PostgREST directly for general reads, strictly governed by these rules:
1. **RLS Applies:** RLS intercepts all reads automatically.
2. **Soft Deletes:** Clients MUST append `&is_deleted=eq.false` to all Master Data queries.
3. **Pagination:** All UI/API lists MUST use **Keyset/Cursor Pagination** on immutable cursor columns (`created_at`). `OFFSET` pagination is forbidden. Max page size is capped at `200`.
4. **Deterministic Ordering:** All queries must explicitly order by the cursor column.

**The `rpc_bootstrap` Exception:**
The initial offline cache sync uses a dedicated RPC returning versioned, structured JSON to ensure atomic local initialization:
```json
{
  "schema_version": 3,
  "products": [...],
  "categories": [...],
  "tax_rates": [...],
  "settings": [...]
}
```

---

## 4. Core Write RPC Definitions

### 4.1 `rpc_process_sale`
**Validation Requirements:**
- Product exists, belongs to `shop_id`, and `is_deleted = false`.
- Quantity > 0, Unit Price $\ge$ 0, Tax Rate is valid.
- Duplicate product lines are forbidden (must be merged into quantity).
- `grand_total` exactly equals `subtotal + tax_total - discount_total`.
- Customer exists and belongs to `shop_id` (if provided).
- Payment method is valid enum.

### 4.2 `rpc_refund_sale`
**Validation Requirements:**
- Original sale exists and belongs to `shop_id`.
- Refunded quantities cannot exceed originally sold quantities.
- Returned products belong to the original sale line items.
- Sale is not already fully refunded.
- `refund_amount` does not exceed remaining refundable balance.

### 4.3 `rpc_adjust_stock`
Handles manual physical stock corrections. It branches validation based on event type.
- **If Damage/Loss:** `quantity_change` MUST be negative. `change_reason` is mandatory.
- **If Purchase:** `quantity_change` MUST be positive. `supplier_id` is mandatory.
- **If Count Correction:** Can be positive or negative. Requires Manager/Owner role.

### 4.4 `rpc_create_product` (and `rpc_bulk_create_products`)
- **Validation:** Enforces barcode/SKU uniqueness across the shop (where `is_deleted = false`). 

### 4.5 `rpc_create_customer` (and `rpc_bulk_import_customers`)
- **Validation:** Enforces exact phone number uniqueness across the shop. Returns `CUSTOMER_PHONE_EXISTS` gracefully to the UI.

### 4.6 `rpc_process_credit_payment`
Handles a customer paying off a standing account balance.
- **Validation:** Customer exists, `payment_amount > 0`, and the payment does not exceed the customer's outstanding negative balance (prevents overpayment into positive credit).
