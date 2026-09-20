# Product Requirements Document — StoreMate

| Field        | Value                                              |
|--------------|----------------------------------------------------|
| Version      | 1.4                                                |
| Status       | Locked                                             |
| Owner        | Pratik Khose                                       |
| Last Updated | 2026-09-09                                         |
| Audience     | Product, Engineering, Design, AI Agents            |
| Dependencies | README.md, 00-AI-INSTRUCTIONS.md, Engineering-Principles.md |

> This document is considered stable. Changes require architectural review and an entry in the Document History.

## Document History

| Version | Date       | Changes                                                                 |
|---------|------------|-------------------------------------------------------------------------|
| 1.4     | 2026-09-09 | Final ambiguity elimination: permission matrix, error UX, search specs. |
| 1.3     | 2026-09-09 | Added state models, feature interactions, and inventory adjustments.    |
| 1.2     | 2026-09-08 | Structural fixes, separation of business rules.                         |
| 1.1     | 2026-09-07 | Initial PRD format improvements.                                        |
| 1.0     | 2026-09-01 | Initial draft.                                                          |

---

## 1. Purpose

This document is the **business contract** for StoreMate. It specifies **what** the product must do — features, user roles, workflows, user stories, acceptance criteria, and explicit out-of-scope items.

It deliberately avoids **how** those requirements are fulfilled. Implementation details, technology choices, database schema, and architecture belong in:

- `02-TRD.md` — Technical constraints and non-functional requirements.
- `03-System-Architecture.md` — Architecture, component relationships, data flow.
- `04-Database-Design.md` — Schema, access policies, stored procedures.

### PRD vs. Business Rules Boundary

This PRD defines **observable product behaviour**, UI workflows, and user capabilities. 

The separate `06-Business-Rules.md` document defines calculations, precedence, validation rules, sequencing, rounding, allocation algorithms, and regulatory logic. Where a feature's behaviour depends on a business rule, this document references it rather than inlining the rule, preventing future duplication and keeping the PRD stable.

Every feature in StoreMate must trace back to a requirement in this document. Features not listed here are considered out of scope and require product review before implementation.

---

## 2. Problem Statement

Indian small and medium retail businesses — kirana stores, grocery shops, medical stores, electronics shops, hardware stores, and similar — currently lack affordable, reliable point-of-sale and inventory management tools designed for their operating environment.

### Pain Points

| Problem                         | Impact                                                       |
|---------------------------------|--------------------------------------------------------------|
| Expensive POS systems           | Most existing solutions are priced for enterprise; SMEs cannot justify the cost. |
| Cloud dependency                | Solutions assume stable broadband. Indian retail operates on patchy 3G/4G mobile data. |
| Western-centric design          | Workflows assume trained staff, standardised barcodes, and non-Indian tax structures. |
| No GST support                  | Indian retailers need GST-compliant invoicing out of the box. |
| Complex onboarding              | Existing tools require technical expertise that most shopkeepers lack. |
| No single-device operation      | Many solutions require dedicated hardware, PCs, or multiple devices. |
| Manual record-keeping           | Without digital tools, stock counts, customer data, and sales records are maintained on paper, leading to errors and lost revenue. |

### Opportunity

A single Android application that any Indian retailer can install, set up in under five minutes, and use to run their entire operation — inventory, billing, customers, invoices, and reporting — from one device, with or without reliable internet.

---

## 3. Vision

StoreMate aims to become the **go-to retail management app for Indian SMEs**. The product vision is a platform where any retailer can:

- Onboard in under five minutes.
- Manage their entire inventory and sales workflow from a single device.
- Gain actionable business intelligence without technical expertise.
- Operate reliably regardless of network conditions.

> [!NOTE]
> The vision extends beyond the features documented in this PRD. Capabilities such as multi-store management, supplier integration, and advanced analytics are long-term aspirations described in the phased roadmap (Section 15) and detailed in `10-Development-Roadmap.md`. They are explicitly out of scope for the product as currently defined.

---

## 4. Tenant Model & Data Ownership

The current product supports **one shop per tenant**. All data — products, sales, customers, staff, audit logs — belongs to a single shop and is completely isolated from other shops.

**Data Ownership:** The **Owner** role exclusively owns the shop and all its data (products, customers, invoices). Staff members create and modify data on behalf of the shop, not themselves. This ensures that if a staff member leaves, the shop retains all records seamlessly for auditing and continuity.

**One phone, one shop.** A phone number can be associated with exactly one shop. A phone number that already belongs to another shop cannot be invited or registered to a second shop.

This constraint is referenced throughout the document. Multi-store support is a future roadmap item and is out of scope for the product as currently defined.

---

## 5. Target Users

### 5.1 Primary Audience

Indian small and medium retail businesses, including but not limited to:

- Kirana (grocery) stores
- Medical stores / pharmacies
- Electronics and mobile shops
- Hardware stores
- Cosmetic and beauty stores
- Stationery shops
- Gift shops
- Clothing stores
- General retail stores

### 5.2 Common User Characteristics

- Typically owner-operated with zero to five staff members.
- Primary device is an Android smartphone or tablet.
- Variable internet connectivity (urban 4G to rural 3G with frequent drops).
- Limited technical expertise; expects to learn by doing.
- Requires Indian language readiness (future; English and Hindi priority).
- Handles mixed product types: barcoded products and non-barcoded ("loose") goods.

---

## 6. User Personas and Roles

### 6.1 Persona: Store Owner (Rajesh)

| Attribute         | Detail                                                    |
|-------------------|-----------------------------------------------------------|
| Business          | Kirana store, 800–1,200 products                          |
| Technical skill   | Can use a smartphone; no computer experience              |
| Primary goals     | Know what is selling, prevent stock-outs, generate GST invoices, track daily earnings |
| Pain points       | Paper ledger is error-prone; loses track of credit customers; cannot calculate profit accurately |
| Success metric    | Reduces daily closing time from 45 minutes to 10 minutes  |

### 6.2 Persona: Store Manager (Priya)

| Attribute         | Detail                                                    |
|-------------------|-----------------------------------------------------------|
| Business          | Electronics shop, 2 staff                                 |
| Technical skill   | Comfortable with apps; uses UPI daily                     |
| Primary goals     | Monitor staff sales, manage stock arrivals, handle returns, run weekly reports |
| Pain points       | Cannot see real-time stock levels; staff theft is a concern |
| Success metric    | Stock variance drops below 2%                             |

### 6.3 Persona: Cashier / Staff (Amit)

| Attribute         | Detail                                                    |
|-------------------|-----------------------------------------------------------|
| Business          | Works at a medical store; does not own the business       |
| Technical skill   | Uses smartphone; learns by doing                          |
| Primary goals     | Bill customers quickly, scan barcodes, process returns    |
| Pain points       | Needs fast checkout; cannot afford errors in billing      |
| Success metric    | Average checkout time under 30 seconds for a 5-item bill  |

### 6.4 Global Permission Matrix

This matrix is the **single source of truth** for access control. Role boundaries are enforced by the system. A staff member cannot escalate their own permissions.

| Module | Owner | Manager | Staff |
|---|:---:|:---:|:---:|
| **POS (Billing)** | ✓ | ✓ | ✓ |
| **Apply Discounts** | ✓ | ✓ | ✗ |
| **Override Prices** | ✓ | ✓ | ✗ |
| **Products (CRUD)** | ✓ | ✓ | View Only |
| **Categories (CRUD)** | ✓ | ✓ | View Only |
| **Inventory (Stock-In/Adjust)** | ✓ | ✓ | ✗ |
| **Customers (CRUD)** | ✓ | ✓ | ✓ |
| **Sales History** | ✓ | ✓ | Own Sales Only |
| **Refunds (Initiate)** | ✓ | ✓ | ✗ |
| **Reports** | ✓ | ✓ | ✗ |
| **Dashboard Metrics** | Full | Full | Limited |
| **Staff Management** | ✓ | ✗ | ✗ |
| **Settings** | ✓ | ✗ | ✗ |
| **Audit Logs** | ✓ | ✗ | ✗ |
| **Backup / Restore** | ✓ | ✗ | ✗ |
| **Credit Sales / Payments** | ✓ | ✓ | ✗ |
| **Ownership Transfer** | ✓ | ✗ | ✗ |

---

## 7. Priority Definitions

| Level | Name                     | Meaning                                                                 |
|-------|--------------------------|-------------------------------------------------------------------------|
| P0    | Launch Requirement       | Must be complete before the product can be released to users.           |
| P1    | Operational Maturity     | Required for the product to be viable for sustained daily use. May ship after initial launch. |
| P2    | Planned Enhancement      | Adds significant value but does not block release or daily operation.   |

---

## 8. Feature Requirements

Features are grouped by functional module. Each module is assigned a **Feature ID** (FR-xxx) for traceability across the PRD, TRD, database design, and test plans.

### 8.0 Global Error UX

When any operation fails across the application, the system must adhere to these UX conventions. These rules apply universally:
- **Never lose entered data**: A failed network request or validation error must return the user to their form with all entered data intact.
- **Human-readable messages**: Display clear, actionable messages (e.g., "Check your internet connection and try again") rather than raw technical errors.
- **Retry capability**: Allow the user to retry the operation where possible.
- **Never expose technical errors**: Do not show SQL errors, API timeouts, or internal stack traces.
- **Maintain consistent state**: An operation must fully succeed or fully fail. The system must never be left in a partially saved or corrupted state.

### Standard CRUD Capability

Many modules provide standard create, read, update, and search operations. The following capability applies to any module managing a data entity (products, categories, customers, staff):

- Users with appropriate permissions (see Section 6.4) can create, view, edit, and search records.
- All records are scoped to the current shop (see Section 4).
- Search results appear without noticeable delay.

**Empty states:** When a module has no data, the screen displays a clear empty-state message explaining what the module does and a prominent action to create the first record (e.g., "No products yet — tap to add your first product"). Empty states must never show a blank screen or generic error.

Detailed user stories below focus on **workflow-specific behaviour** that goes beyond standard CRUD.

---

### 8.1 Authentication (FR-AUTH)

**Priority: P0**

#### Description
Users authenticate using their mobile phone number via OTP verification. No passwords.

#### Acceptance Criteria
- [ ] OTP is delivered within 30 seconds of request.
- [ ] OTP entry accepts exactly 6 digits.
- [ ] Session persists across app restarts until explicit logout.
- [ ] Invalid or expired OTPs show a clear error message.
- [ ] After successful verification, new users are routed to shop registration; returning users to the dashboard.
- [ ] OTP resend is available after a 30-second cooldown period, visible to the user.
- [ ] After repeated failed OTP attempts, the user is temporarily locked out with a retry time.
- [ ] A phone number already belonging to another shop cannot create a new shop.

---

### 8.2 Shop Management (FR-SHOP)

**Priority: P0**

**Depends on:** FR-AUTH

#### Description
After first login, the user creates a shop profile. The shop is the tenant boundary.

#### Shop Profile Fields
| Field               | Required | Notes                                              |
|---------------------|----------|----------------------------------------------------|
| Shop Name           | Yes      |                                                    |
| Owner Name          | Yes      |                                                    |
| Business Type       | Yes      | Selectable from predefined list                    |
| Address             | No       |                                                    |
| Phone               | No       |                                                    |
| Email               | No       |                                                    |
| GST Number (GSTIN)  | No       | Validated against 15-character Indian GSTIN format |
| Logo                | No       |                                                    |
| Invoice Prefix      | No       | Defaults to "INV"                                  |
| UPI / Bank Details  | No       | Displayed on invoices if set                       |
| Currency            | Fixed    | INR (₹). Not user-configurable.                    |
| Locale / Timezone   | Fixed    | IST (UTC+5:30). Not user-configurable.             |

#### Shop Deletion and Data Retention
- Shops **cannot be deleted by any user**. Shop closure requires contacting support to prevent accidental data loss.
- Before shop closure, the owner must be offered a complete data export.

#### Ownership Transfer
- Only the current owner can initiate transfer to an existing staff/manager.
- After transfer, the previous owner becomes a Manager. Recorded in audit log.

---

### 8.3 Product Management (FR-PROD)

**Priority: P0**

**Depends on:** FR-SHOP, FR-CAT (optional)

#### Description
The product catalogue is the core of StoreMate. Products can be added manually, via barcode scan, or bulk import.

#### Product Pricing Model
- **Purchase Price**: Cost price paid to the supplier (Required).
- **Selling Price**: Price charged to the customer at POS (Required).
- MRP, Wholesale Price, Minimum Selling Price, and Tiered pricing are **explicitly out of scope**.

#### Product Variants
Product variants (size, colour) are **not supported**. Each SKU is a distinct product record.

#### Search Specification
Searchable fields: **Name, Barcode, SKU, Category Name**.
Ranking: Exact name match → Name starts with → Name contains → Barcode exact match → SKU exact match.

#### Barcode Uniqueness & Cascade
- Barcodes must be unique per shop. Duplicate barcodes are rejected.
- Barcode scan resolves via: Local DB → Local Cache → External API (food) → External API (non-food) → Manual entry.
- **Data Ownership**: Once saved locally, the local record is the authoritative version and is never overwritten by external APIs on future scans.

#### Bulk Import Failure Behaviour
If bulk importing a CSV:
- **Duplicate detection**: Existing barcodes in the file are skipped or flagged.
- **Validation report**: Shows successful row count, skipped rows, and reasons for failure (e.g., missing mandatory field, invalid GST).
- **Partial import**: Valid rows are saved even if other rows fail.

#### Acceptance Criteria
- [ ] Product creation requires name, selling price, purchase price, quantity, and unit type.
- [ ] Unit type is selectable from supported Indian units (Piece, Kg, Gram, Litre, Box, etc.).
- [ ] Low-stock threshold defaults to 5, editable per product.
- [ ] Import provides duplicate detection, preview, and validation report.

---

### 8.4 Category Management (FR-CAT)

**Priority: P0**

**Depends on:** FR-SHOP

#### Description
Categories organise the product catalogue. Deleting a category does not delete its products; they become uncategorised.

---

### 8.5 Inventory Management (FR-INV)

**Priority: P0**

**Depends on:** FR-PROD

#### Description
Inventory tracks product quantities. The system supports explicit inventory movement types.

#### Inventory Movement Types
1. **Sale**: Automatic deduction.
2. **Refund**: Automatic restoration.
3. **Stock-In**: Manual addition (with purchase price / reason).
4. **Stock Adjustment**: Manual correction (increase/decrease).
5. **Initial Stock**: Opening balance.

#### Stock Adjustments (FR-ADJUST)
Users must provide a reason for manual adjustments:
- Loss (Decrease)
- Damage (Decrease)
- Expired (Decrease)
- Count Correction (Increase/Decrease)
- Opening Stock (Increase)

#### Acceptance Criteria
- [ ] Sale cannot reduce stock below zero. If insufficient, sale is rejected.
- [ ] Failed checkout leaves inventory unchanged.
- [ ] All movements are recorded in the audit log.

---

### 8.6 Point of Sale / Billing (FR-POS)

**Priority: P0**

**Depends on:** FR-PROD, FR-INV, FR-SHOP, FR-DISCOUNT

#### Description
The primary operational screen to build a cart, apply discounts, and checkout.

#### Manual Items
Items not in the catalogue can be added manually.
- **Edit Behaviour**: Name, GST, quantity, and price can be edited *before* checkout while in the cart. After checkout, they are locked.
- **"Sell Only"**: Does not affect inventory.
- **"Save to Inventory"**: Creates a product record and deducts stock.

#### Held Carts
- Carts can be parked with a reference name.
- Held carts are visible to all users of the same shop.
- Expire automatically after 24 hours.

#### Acceptance Criteria
- [ ] POS search remains responsive while typing.
- [ ] Running total recalculates instantly on every cart change.
- [ ] A sale is never partially completed. Entire sale succeeds, or nothing changes.

---

### 8.7 Discounts (FR-DISCOUNT)

**Priority: P0**

#### Description
Discounts (percentage or fixed amount) can be applied to individual items or the entire invoice. Only Owners/Managers can apply discounts.

---

### 8.8 Credit Sales (FR-CREDIT)

**Priority: P0**

**Depends on:** FR-POS, FR-CUST

#### Description
Sales completed with "Credit" track the amount as a receivable against the customer.

#### Credit Lifecycle
**Outstanding** → **Partial Payment** → **Settled**.
Tracking overdue payments or late fees is **out of scope**.

#### Acceptance Criteria
- [ ] Credit sales require a named customer.
- [ ] A payment cannot exceed the customer's outstanding balance (no overpayment).

---

### 8.9 Sales History (FR-SALES)

**Priority: P0**

#### Description
Chronological record of sales.
Searchable fields: **Invoice Number, Customer Name, Payment Method, Date Range**.

---

### 8.10 Invoice Generation (FR-INVOICE)

**Priority: P0**

#### Description
Generates a PDF invoice for sharing.

#### Failure Behaviour
- If PDF generation fails, show clear error and a "Retry" option.
- If Share sheet is unavailable, show a clear toast message.
- Invoice generation failure **never** blocks the sale workflow.

---

### 8.11 Refund System (FR-REFUND)

**Priority: P0**

#### Description
Allows full or partial refunds, restoring stock and creating an audit trail.

#### Refund Edge Cases
- **Fully Refunded Status**: If all items are refunded, the sale status transitions permanently to "Fully Refunded".
- **Refund Method**: Can differ from the original payment method.
- **Refund Note**: The original invoice remains unchanged; a separate refund note is generated.
- **Cancellation**: A processed refund cannot be cancelled or reversed.

---

### 8.12 Customer Management (FR-CUST)

**Priority: P0**

#### Description
Directory for customer contact and purchase history.
Searchable fields: **Name, Phone Number**.

#### Duplicate Handling
Phone numbers are unique per shop. If a user attempts to create a duplicate, the system rejects it and displays the existing customer record.

---

### 8.13 Reports and Analytics (FR-REPORTS)

**Priority: P1**

#### Description
Business intelligence for owners/managers (revenue, trends, top products).

#### Export & Sharing
- Can reports be exported? **No** (Phase 3).
- Can reports be shared? **No** (Phase 3).
- Can reports be printed? **No** (Phase 3).

---

### 8.14 Dashboard (FR-DASH)

**Priority: P1**

#### Dashboard Widgets by Role

**Owner / Manager**
- Revenue (Today)
- Transaction Count (Today)
- Top Products (Today)
- Low Stock Alerts
- Pending Credit Sales
- Today's Refunds

**Staff**
- POS Shortcut
- Held Carts Count
- Personal Sales (Today)

Dashboard layout and widgets are **fixed**. Customisation is not available.

---

### 8.15 Staff Management (FR-STAFF)

**Priority: P1**

#### Description
Owners invite staff by phone number. Staff see permission-restricted views.

---

### 8.16 Audit / Activity Logs (FR-AUDIT)

**Priority: P1**

#### Audit Policy
- **Retention**: Audit logs are retained forever. They are never automatically purged.
- **Export**: Audit logs cannot be exported in the current phase.
- **Search**: Logs are searchable by date range and event type. They are displayed chronologically.

---

### 8.17 Settings (FR-SETTINGS)

**Priority: P0**

#### Sections
The settings screen includes:
- **Shop Profile**: Name, address, GST, logo.
- **Invoice**: Prefix, terms, tax toggle.
- **Printer**: Pair, disconnect, test print.
- **Backup & Restore**: Manual backup, restore from file.
- **Display**: Theme (Light/Dark/System), Language (English).
- **Notifications**: Alert preferences.
- **About / Support**: App version, contact help, logout.

---

### 8.18 Thermal Printer Integration (FR-PRINT)

**Priority: P1**

#### Failure Behaviour
- **Printer disconnected**: Notify user, save the sale, allow printing from history later.
- **Paper out**: Handle standard Bluetooth printer errors gracefully.

---

### 8.19 Barcode Scanner (FR-SCAN)

**Priority: P0**

#### Timeout Behaviour
If an external API lookup exceeds 3 seconds, the system silently aborts the network request and proceeds to the manual entry screen with the barcode pre-filled. The user is never left waiting indefinitely.

---

### 8.20 Notifications (FR-NOTIFY)

**Priority: P1**

#### Low-Stock Alert Behaviour
- **Where does it appear?** Dedicated widget on the Dashboard, and badge on the Inventory icon.
- **Who sees it?** Owner and Manager roles only.
- **Frequency?** Continually displayed as long as the product is below the threshold.
- **Push Notification?** Not in scope.

---

### 8.21 Offline Capability (FR-OFFLINE)

**Priority: P1 (graceful degradation), P2 (full offline)**

Core POS continues during network interruptions, syncing when restored.

---

### 8.22 Data Backup and Restore (FR-BACKUP)

**Priority: P1**

#### Failure Behaviour
- **Backup interrupted**: Marked as failed; does not overwrite previous backups.
- **Insufficient storage**: Validated before starting, shows clear error if storage is full.
- **Version Compatibility**: Older → newer is supported; newer → older is rejected.

---

## 9. Entity Lifecycle Matrix

This matrix defines the archival and deletion policy for all entities.

| Entity | Edit | Deactivate | Delete |
|---|:---:|:---:|---|
| **Product** | ✓ | ✓ | Only if unused in any transaction. |
| **Customer**| ✓ | ✓ | Only if unused in any transaction. |
| **Staff** | ✓ | ✓ | Never (preserved for audit integrity). |
| **Category**| ✓ | ✗ | ✓ (Products become uncategorised). |
| **Sale** | ✗ | ✗ | Never. |
| **Refund** | ✗ | ✗ | Never. |
| **Shop** | ✓ | ✗ | Support request only. |

---

## 10. Feature Interaction Rules

1. **Discounts ↔ Refunds**: Refund amount reflects the discounted price.
2. **Discounts ↔ Reports**: Reports show gross revenue and total discounts separately.
3. **Credit ↔ Customer Balance**: Credit sale increases balance; payment decreases it.
4. **Manual Items ↔ Inventory**: "Sell Only" does not affect inventory.
5. **Manual Items ↔ Reports**: "Sell Only" items appear in revenue reports.
6. **Deactivated Products ↔ Sales History**: Remain visible in historical records.
7. **Refunds ↔ Reports**: Excluded from net revenue totals.
8. **Refunds ↔ Credit**: Refund via "Credit Adjustment" reduces customer balance.
9. **Stock Adjustments ↔ Reports**: Do not affect sales revenue.
10. **Discounts ↔ Invoices**: Show both original and discounted price per line item.

---

## 11. User Workflows

*(Workflows omitted for brevity but remain identical to v1.3: First-Time Setup, Daily Sales, Hold Cart, Refund, Stock-In, Stock Adjustment, Barcode Addition, Staff Onboarding, Credit Sale, Ownership Transfer).*

---

## 12. Out of Scope

- E-commerce / online storefront
- Accounting / ERP / CRM
- Multi-store / Supplier management
- iOS / Web / Multi-language
- AI recommendations / Payment gateway processing
- Advanced Profit metrics / Exporting reports
- Dashboard widget customisation
- Push Notifications
- Product Variants

---

## 13. Non-Functional Requirements Summary

(Detailed in `02-TRD.md`).
- Responsiveness: Instant POS operations.
- Security: Isolated tenant data.

---

## 14. Requirement Traceability Matrix (Example)

To aid QA, every feature should trace to acceptance criteria and business rules.

| Feature ID | User Story | Acceptance Criteria | Business Rule Ref |
|---|---|---|---|
| FR-POS | US-POS-09 | Checkout creates sale & deducts stock | BR-POS-01 |
| FR-REFUND | US-REF-04 | Refund method can differ from original | BR-REF-03 |
| FR-CREDIT | US-CREDIT-02 | Payment cannot exceed outstanding balance | BR-CRED-02 |

---

## 15. Phased Delivery Roadmap

(Detailed in `10-Development-Roadmap.md`).
- Phase 1: Core POS
- Phase 2: Operational Maturity
- Phase 3: Business Intelligence
- Phase 4: Offline Operation
- Phase 5: Multi-Store and Growth

---

## 16. Glossary

*(Terms: POS, GST, Kirana, Held Cart, Stock-In, Stock Adjustment, Manual Item, OTP, Tenant, Deactivation, Ownership Transfer).*

---

## Document Relationships

```
README.md (overview)
├── 00-AI-INSTRUCTIONS.md (governance)
├── Engineering-Principles.md (governance)
└── 01-PRD.md (this document — WHAT)
    ├── 02-TRD.md → HOW (technical constraints, performance budgets)
    ├── 03-System-Architecture.md → HOW (structure)
    ├── 04-Database-Design.md → HOW (data)
    ├── 06-Business-Rules.md → business logic
    └── 10-Development-Roadmap.md → WHEN
```
