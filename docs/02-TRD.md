# Technical Requirements Document (TRD) — StoreMate

| Field        | Value                                              |
|--------------|----------------------------------------------------|
| Version      | 1.2                                                |
| Status       | Draft                                              |
| Owner        | Pratik Khose                                       |
| Last Updated | 2026-09-09                                         |
| Audience     | Engineering, Architecture, QA                      |
| Dependencies | 01-PRD.md, Engineering-Principles.md               |

> [!IMPORTANT]
> This document translates the product requirements of `01-PRD.md` into explicit engineering contracts. It defines *how* the system will technically fulfill the PRD while adhering strictly to `Engineering-Principles.md`. 

---

## 1. Architectural Principles

All technical decisions must align with the following core engineering contracts, derived from `Engineering-Principles.md`:

- **Offline-First UI:** The UI must never block waiting for network requests. Local SQLite data is the primary driver for all reads.
- **Server Authoritative:** In the event of a conflict between the client and server, the server's state strictly overwrites the client.
- **Database Owns Business Logic:** All data validation, constraint checking, and access control reside in Supabase (PostgreSQL).
- **RPCs are the Only Write Entry Point:** Direct table mutations (`supabase.from('table').insert()`) from the client are strictly prohibited. All writes go through PostgreSQL RPCs.
- **Idempotent RPCs:** Every write RPC must safely retry. If a sync worker retries a queued request, the database must safely handle duplicates via UUID idempotency keys.
- **Immutable Financial Records:** Completed sales and financial transactions must never be edited (no `UPDATE`). Corrections happen exclusively via refunds, cancellations, or manual adjustments.
- **Soft Delete Policy:** No production data with foreign key references is physically deleted. Deactivated records are hidden from active queries but preserved for audit integrity.

---

## 2. Technical Contracts

To prevent architectural drift, the following constraints apply to specific layers:

- **UI Layer:** Widgets must never access Supabase or SQLite directly. They only consume state from Riverpod Controllers. DTOs (Data Transfer Objects) must never leak into widgets.
- **Controller Layer:** Controllers manage UI state but never contain business logic.
- **Repository Layer:** Repositories orchestrate local/remote data flow but never contain business logic.
- **Domain Layer:** Domain models must be deeply immutable (Freezed).
- **RPC Layer:** RPCs must return structured domain error codes; they must never return raw SQL errors or expose database internals to the client.
- **Storage Layer:** SQLite must never store unencrypted secrets, tokens, or credentials.

---

## 3. Performance Budgets (Engineering SLA)

The following performance budgets are strictly enforced SLAs. Targets are measured on a mid-range Android device over typical 3G/4G network conditions.

| Operation               | Target Budget | Fallback / Behavior |
|-------------------------|---------------|---------------------|
| Login                   | < 2s          | Show loading spinner. |
| Reconnect (Realtime)    | < 1s          | Background retry. |
| Dashboard load          | < 500ms       | Load from local cache. |
| Product search          | < 100ms       | Synchronous local SQLite query. |
| Barcode lookup (local)  | < 500ms       | UI feels instant. |
| Barcode lookup (API)    | < 3s (timeout)| Silently abort; route to manual entry screen. |
| Cart update             | < 100ms       | Synchronous Riverpod state calculation. |
| Checkout                | < 1s          | Non-blocking; clear cart on queue submission. |
| Refund                  | < 1s          | Non-blocking UI. |
| Product save (local)    | < 100ms       | Instant local commit, queue for sync. |
| Sync latency            | Background    | Target flush within 5s of online status. |
| Product import          | Progress req. | Background isolate processing with progress bar. |
| Invoice generation (PDF)| < 2s          | Isolate rendering. |
| PDF share               | Non-blocking  | Trigger native share sheet immediately. |
| Report generation       | < 2s          | Database materialized views or RPC aggregation. |
| Backup creation         | < 5s          | Background operation with progress. |
| Restore database        | < 10s         | Force app restart after completion. |

---

## 4. Offline Architecture & Sync Engine

### 4.1 Deterministic Local Computation + Server Authoritative Validation
To fulfill the PRD's true offline POS requirement (Phase 4) without violating the "Thin Flutter" rule, StoreMate divides business logic into two strict categories:

1. **Deterministic Local Rules (Flutter):**
   Flutter may execute only rules that are deterministic and purely mathematical to allow offline operation. This includes: subtotal calculation, GST display calculations, discount previews, cart totals, quantity math, and invoice preview generation. These calculations *never* become authoritative.
2. **Server Authoritative Rules (Supabase):**
   Validation and finalized business logic remain exclusively in Supabase. This includes: official invoice numbering, exact stock deduction, inventory validation, audit log generation, loyalty/credit validation, and refund eligibility.

**Offline Workflow:**
When a sale is completed offline, the transaction receives a temporary local ID. Inventory is shown as "pending sync". When connectivity is restored, the server validates and processes the intent. Conflicts are handled explicitly.

### 4.2 Sync Engine
The background sync worker manages the intent queue (SQLite `sync_queue` table).

- **Queue Ordering:** Strict execution order to prevent dependency failures: `Financial (Sales/Refunds) $\rightarrow$ Inventory (Stock-In/Adjust) $\rightarrow$ Master Data (Products/Customers) $\rightarrow$ Analytics`.
- **Retry Policy:** Failed syncs backoff exponentially: `1m, 2m, 4m, 8m, 15m, 30m`. After 30 minutes, the item stops auto-retrying.
- **Idempotency Key:** Every queued intent must generate a client-side UUID. The server ignores duplicates matching this UUID.
- **Dead-Letter Queue:** Permanent failures (e.g., HTTP 400 Validation Error) must not block the queue. They are moved into a `sync_failed` table for manual owner review.

### 4.3 Caching Strategy
- **Ownership:** SQLite is the *source of truth* while offline, and a *mirror* while online. Supabase remains the ultimate authority.
- **Cache Warming / Cold Start:** On initial login, a bulk data RPC pulls all shop products, categories, and customers to seed SQLite.
- **TTL & Invalidation:** Master data invalidates via Realtime events when online. If offline for > 24 hours, the cache is flagged as stale, prompting a full delta sync upon reconnect.

---

## 5. Backend Integration

### 5.1 RPC Strategy
All write operations must go through PostgreSQL RPCs.
- **Rule:** Never use direct table mutation.
- **Naming Convention:** `create_product()`, `update_product()`, `process_sale()`, `refund_sale()`, `record_payment()`. Mixed naming is prohibited.

### 5.2 Realtime Strategy
To prevent unnecessary connection overhead, Realtime boundaries are strictly defined.

- **Realtime Enabled (Dynamic Data):** Inventory, Sales, Credit payments, Staff role changes.
- **Polling / Manual Refresh (Static Data):** Categories, Settings, Customers, Products, Reports.

---

## 6. Frontend Architecture

### 6.1 State Management Rules (Riverpod)
Strict layered ownership prevents logic leaking into UI:
`UI (Widget) $\rightarrow$ Controller (StateNotifier) $\rightarrow$ Repository $\rightarrow$ RPC Service $\rightarrow$ Supabase $\rightarrow$ SQLite $\rightarrow$ Provider Refresh`

- **Provider Lifetime:** Use `.autoDispose` by default for all feature-specific providers to prevent memory leaks. Global providers remain alive.

### 6.2 Dependency Injection
Dependencies are managed exclusively via Riverpod with explicit lifetimes:
- **Singleton:** Supabase Client, SQLite database instance, Logger, Connectivity Service, Printer Service.
- **Scoped:** UI Controllers, Feature-specific providers.
- **Transient:** DTOs, Mappers (instantiated on demand).

---

## 7. Error Handling & Observability

### 7.1 Error Taxonomy
All exceptions map to unified domain errors, mapping to specific UI behaviors:
- **Authentication:** Force logout.
- **Authorization:** Show "Access Denied".
- **Validation:** Highlight form fields.
- **Business Rule:** Show contextual dialog (e.g., "Cannot refund beyond total").
- **Conflict:** Show reconciliation dialog.
- **Offline:** Toast "Action queued offline".
- **Network / Timeout:** Show retry button.
- **Cancelled:** Silent abort.
- **Rate Limit:** Show backoff timer.
- **Unexpected:** Log to crash reporter; generic snackbar.

### 7.2 Observability & Logging Strategy
- **Performance Metrics:** Track RPC latency, sync duration, failed sync counts, barcode lookup duration, and startup time.
- **Crash Logging:** Capture unhandled exceptions via analytics.
- **PII Masking:** **Never** log phone numbers, GST numbers, authentication tokens, or customer names. All PII must be masked before leaving the device.

---

## 8. Hardware, Files & Background Jobs

### 8.1 Hardware Abstraction
The TRD relies on architectural interfaces, not concrete packages.
- `BarcodeScannerService`: Abstracts camera activation and ML parsing.
- `PrinterService`: Manages connection lifecycle, reconnect logic, and receipt formatting abstraction.
- `StorageService`: Manages local persistence.

### 8.2 File Storage Strategy
Files stored in Supabase or locally must follow strict naming conventions:
- `shops/{shop_id}/products/{product_uuid}.jpg`
- `shops/{shop_id}/receipts/{invoice_id}.pdf`
- `shops/{shop_id}/exports/{timestamp}.csv`
- `shops/{shop_id}/backups/{timestamp}.enc`

### 8.3 Background Jobs
The following tasks run outside the main UI thread:
1. **Sync Worker:** Flushes the intent queue.
2. **Backup Worker:** Generates and encrypts local SQLite backups.
3. **Cleanup Worker:** Wipes expired held carts (older than 24h) and temporary PDFs.
4. **Token Refresh:** Supabase auth background refresh.
5. **Realtime Reconnect:** Restores socket connections after network drops.
6. **Cache Cleanup:** Evicts orphaned images.

---

## 9. Data Import & Backup

### 9.1 Import Architecture
- **Pipeline:** CSV Parsing (Isolate) $\rightarrow$ Validation Pipeline $\rightarrow$ Chunking (e.g., 100 rows) $\rightarrow$ Execute RPC $\rightarrow$ Error Reporting.
- Rollbacks apply to individual failed chunks, preserving valid rows.

### 9.2 Backup Strategy
- **Encryption:** Backup files must be AES-256 encrypted derived from the owner's Auth ID.
- **Compression:** Zlib compressed to minimize disk usage.
- **Restore Validation:** Validates SQLite schema version before restoring.
- **Overwrite Behavior:** Restoring a backup completely overwrites the local DB and forces a full server reconciliation sync.

---

## 10. Security Requirements

- **Token Storage:** JWTs stored securely using `flutter_secure_storage` (Android Keystore).
- **Certificate Pinning:** Not required for current phase, relying on standard HTTPS/TLS to Supabase.
- **API Key Handling:** Supabase `anon` key is public; Service Role keys are strictly forbidden in the client.

---

## 11. Testing Requirements

Code must meet these minimum coverage constraints before PR approval. This is a strict engineering contract.
- **Business RPCs:** 100% coverage (pgTAP or equivalent).
- **Repositories:** 90% coverage (Mocked DB clients).
- **Controllers:** 80% coverage (State transition validation).
- **Widgets:** Critical flows only (Checkout, Barcode scan, Login).
- **Integration/E2E:** Sync worker queue processing.

---

## 12. Technical Risks & Mitigations

| Risk | Mitigation Strategy |
|------|---------------------|
| **SQLite Corruption** | Complete local data loss. Server acts as Source of Truth; clear and resync SQLite. |
| **Printer Incompatibility** | Fragmented Bluetooth stacks. Use standard ESC/POS; provide explicit "Test Print" tools. |
| **Barcode API Outage** | Strict 3s timeout $\rightarrow$ fallback to manual entry. Workflow never blocks. |
| **Duplicate Sync** | Enforce UUID idempotency keys on every write RPC. |
| **Clock Skew** | Use Supabase `now()` for financial timestamps, never local device time. |
| **Storage Exhaustion** | Strict cache eviction; reject DB backup if free space < 100MB. |
| **Android Battery Optimizations** | Background workers killed. Sync engine must wake and flush immediately upon app foregrounding. |

---

## 13. Technical Decisions Log (ADRs)

| Decision | Reason |
|----------|--------|
| **ADR-001: Supabase Chosen** | Centralized Postgres backend with built-in Auth, RLS, and RPCs enforcing business rules. |
| **ADR-002: Riverpod Selected** | Compile-time safety, strict dependency injection, and deterministic state flows. |
| **ADR-003: SQLite Mirror Arch.** | Provides necessary local persistence for true offline POS search and reads. |
| **ADR-004: RPC-Only Writes** | Ensures atomic transactions and strict business logic encapsulation on the server. |
| **ADR-005: Offline Queue Model** | Decouples offline financial intents from network reliability without duplicating complex validation locally. |
