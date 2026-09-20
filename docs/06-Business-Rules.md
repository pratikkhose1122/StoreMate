# Business Rules Document — StoreMate

| Field        | Value                                              |
|--------------|----------------------------------------------------|
| Version      | 1.0                                                |
| Status       | Draft                                              |
| Owner        | Pratik Khose                                       |
| Last Updated | 2026-09-09                                         |
| Audience     | Backend Engineers, Flutter Engineers               |
| Dependencies | 01-PRD.md, 04-Database-Design.md, 05-API-Contracts.md |

> [!IMPORTANT]
> This document defines the exact mathematical, logical, and resolution formulas for StoreMate. **Both the Flutter POS (offline) and the Supabase RPCs (server)** must implement these identical mathematical rules to prevent drift and `VALIDATION_FAILED` synchronization rejections.

---

## 1. Global Calculation Contract

To ensure physical receipts match the exact totals synced to the database, calculation order and rounding must be deterministic.

### 1.1 Rounding Algorithm
- **Algorithm:** Standard `Round Half Up` to **2 decimal places**. (e.g., `2.445` rounds to `2.45`. `2.444` rounds to `2.44`).
- **Precision Type:** In Dart/Flutter, this is achieved via the `Decimal` library. **Never use standard floating-point `double` for currency.**

### 1.2 Line-Item Rounding Paradigm
StoreMate strictly uses **Line-Item Rounding**.
- **Rule:** Tax and discount amounts are calculated and rounded to 2 decimal places for *each individual item* on the receipt, and then summed to create the grand total.
- **Why:** This ensures that if a customer manually adds up the printed taxes on their receipt line-by-line, it perfectly matches the printed grand total tax. (Grand-Total rounding, where unrounded fractions are summed and then rounded, causes 1-cent discrepancies on printed receipts).

### 1.3 Order of Operations
For any given line item, mathematics must be executed in this exact order:
1. **Gross Amount** = `Quantity * Unit Price`
2. **Discounted Amount** = `Gross Amount - Applied Discounts`
3. **Tax Amount** = Calculate tax on the *Discounted Amount*
4. **Line Total** = `Discounted Amount + Tax Amount`

---

## 2. Tax Application Rules

Different regions require different tax display laws. StoreMate supports both Inclusive and Exclusive tax models, governed by a global `shop_settings.is_tax_inclusive` flag.

### 2.1 Tax-Exclusive Pricing (e.g., US Sales Tax)
The shelf price does not include tax. Tax is added at the register.
- **Formula:** `Tax Amount = Round(Discounted Amount * (Tax Rate / 100))`
- **Example:** A $10 item with 10% tax.
  - Tax = $1.00
  - Line Total = $11.00

### 2.2 Tax-Inclusive Pricing (e.g., AU/UK GST, EU VAT)
The shelf price already includes the tax. The register merely separates it for the receipt.
- **Formula:** `Tax Amount = Round(Discounted Amount - (Discounted Amount / (1 + (Tax Rate / 100))))`
- **Example:** A $11 item (inclusive of 10% tax).
  - Tax = `11 - (11 / 1.1)` = $1.00
  - Line Total = $11.00

### 2.3 Tax Immutability
When a tax rate is updated in the Master Data (e.g., GST changes from 10% to 15%), **historical sales are completely unaffected**.
- `sale_items` stores the exact `tax_amount` and `tax_rate` computed at the exact `business_timestamp` of the transaction.
- Returns and refunds must use the historical `tax_rate` captured on the original `sale_items` row.

---

## 3. Discount Application Rules

### 3.1 Pre-Tax Discounting
Discounts in StoreMate are strictly **Pre-Tax**.
- You do not calculate tax on the original price and then subtract the discount.
- You subtract the discount from the unit price, and calculate tax on the remaining subtotal.

### 3.2 Cart-Level Proportional Distribution
If a cashier applies a global "$10 off entire order" discount, the system **must** distribute that $10 proportionally across all line items based on their weight in the subtotal.
- **Why:** If the discount is applied to the grand total natively, it breaks the ability to refund a single item later (because the system wouldn't know how much of the $10 discount belonged to the refunded item).
- **Formula:** `Item Discount = Total Cart Discount * (Item Gross / Cart Gross)`

---

## 4. Inventory Allocation & Selling Rules

### 4.1 The Negative Inventory Contract
StoreMate is an offline-first POS. Physical reality always wins over database reality.
- If the system says there are `0` apples, but the cashier is holding `3` physical apples in front of a customer, the system **must** allow the sale.
- The `current_stock_projection` will simply drop to `-3`.
- **UI Contract:** The Flutter UI will display an orange "Low Stock" or "Negative Stock" badge, but will **never** disable the checkout button.

### 4.2 Fractional Quantities
Because quantities use `DECIMAL(12,3)`, cashiers can sell `1.500` kg of bulk items. 
- Refunds of fractional items must not exceed the original fraction sold.

---

## 5. Offline Sync Conflict Resolution

When a device connects to the internet after being offline, the Sync Worker flushes the Unified Write Queue. If the server detects a state conflict, it relies on this resolution matrix:

### 5.1 Financial Ledgers (Sales, Refunds, Payments)
Because these are purely append-only ledgers identified by a unique `intent_id`, conflicts are virtually impossible.
- **Rule:** Duplicate `intent_id` $\rightarrow$ **Server Wins** (Server ignores the payload, returns a success cache response to the client).
- **Rule:** Sale contains a `product_id` that the Owner deleted yesterday $\rightarrow$ **Client Wins** (RPC allows the sale, relying on the soft-delete contract `is_deleted = true`).

### 5.2 Master Data (Products, Customers, Settings)
If two offline devices modify the price of the same apple simultaneously and then sync:
- **Rule:** The system enforces **Optimistic Concurrency** using the `version` column.
- The server checks if `p_expected_version == current_version`. 
- If false, the server rejects the request with `VERSION_CONFLICT`.
- **Client Resolution:** The Flutter client moves the intent to the Dead Letter Queue, pulls the latest master data from the server, and alerts the user that their edit was rejected due to a newer version existing.
