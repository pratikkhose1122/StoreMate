# StoreMate

| Field        | Value              |
|--------------|--------------------|
| Version      | 1.0                |
| Status       | Locked             |
| Owner        | Project Owner      |
| Last Updated | 2026-09-09         |

> [!IMPORTANT]
> This document is considered stable. Changes require architectural review and an entry in the Decision Log.


StoreMate is a production-grade Point of Sale, Inventory Management and Customer Management application built for Indian small and medium retail businesses. The system handles the complete retail operations lifecycle from product cataloguing and barcode scanning through billing, invoicing, refunds and sales reporting. Built on Flutter and Supabase, StoreMate is designed for reliability in low-connectivity environments, strict data security through Row Level Security, and a deployment model that scales from a single kirana store to a multi-location retail chain.

---

## Why StoreMate Exists

Existing POS systems are expensive, bloated, cloud-dependent and designed for enterprise users. They assume stable internet, trained staff and workflows borrowed from Western retail. Indian small and medium retailers need something different: a system that works on a single Android device, survives network dropouts, handles Indian-specific concerns like GST and multi-unit pricing, and requires zero technical expertise to operate. StoreMate exists to fill that gap.

---

## Vision

StoreMate aims to become the default operating system for Indian retail. The long-term vision is a platform where any retailer can onboard in under five minutes, manage their entire inventory and sales workflow from a single device, and gain actionable business intelligence without technical expertise. The platform will evolve from a single-store POS into a multi-store, multi-staff, supplier-integrated retail management suite with offline-first capabilities and real-time analytics.

---

## Target Users

- Kirana Stores
- Grocery Shops
- Medical Stores
- Electronics Shops
- Mobile Stores
- Hardware Stores
- Gift Shops
- Cosmetic Stores
- Stationery Shops
- General Retail Stores

---

## Current Status

| Item              | Detail                                         |
|-------------------|-------------------------------------------------|
| Current Version   | v1.0.0                                          |
| Current Milestone | Phase 2 — Operational Maturity                  |
| Next Milestone    | Phase 3 — Business Intelligence and Analytics   |

### Stable Modules

Authentication, Shop Management, Inventory, Product Management, Category Management, POS / Billing, Customer Management, Sales History, PDF Invoice, Refund System, Activity / Audit Logs, Settings.

### Under Development

Reports (expanding), Staff Management, Dashboard, Thermal Printer Integration.

---

## Technology Stack

### Frontend

| Technology           | Purpose                                      |
|----------------------|----------------------------------------------|
| Flutter 3.x          | Cross-platform UI framework                  |
| Dart 3.10+           | Application language                         |
| Riverpod 2.x         | State management                             |
| GoRouter             | Declarative routing and deep linking         |
| Freezed              | Immutable data models and union types        |
| Google Fonts          | Typography                                   |
| FL Chart             | Data visualisation and reporting charts      |
| Mobile Scanner       | Barcode and QR code scanning                 |
| QR Flutter           | QR code generation                           |
| PDF / Printing       | Invoice generation and printing              |
| Share Plus           | Native sharing of invoices and reports       |
| Hive / Hive Flutter  | Local key-value storage and offline cache    |
| Connectivity Plus    | Network state monitoring                     |
| Dio                  | HTTP client for external API calls           |
| Pinput               | OTP input field                              |
| File Picker          | File selection for imports                   |
| Image Picker         | Product image capture                        |
| Path Provider        | Platform-specific file paths                 |
| Timeago              | Human-readable relative timestamps           |
| Intl                 | Number formatting, currency, date formatting |
| Shared Preferences   | Lightweight persistent settings              |
| Flutter Secure Storage | Secure credential storage                  |
| URL Launcher         | External link handling                       |
| Flutter Blue Plus    | Bluetooth connectivity for thermal printers  |
| ESC POS Utils Plus   | ESC/POS command generation for receipt printing |

### Backend

| Technology           | Purpose                                      |
|----------------------|----------------------------------------------|
| Supabase             | Backend-as-a-Service platform                |
| PostgreSQL           | Primary relational database                  |
| Row Level Security   | Data isolation and access control            |
| RPC Functions        | Server-side business logic                   |
| Edge Functions       | Serverless compute (auth bridge, webhooks)   |

### Authentication

| Technology                  | Purpose                                |
|-----------------------------|----------------------------------------|
| Firebase Auth               | Phone OTP verification                 |
| Supabase Auth               | Session management and JWT issuance    |
| Auth Bridge (Edge Function) | Firebase-to-Supabase token exchange    |

### External APIs

| API                  | Purpose                                      |
|----------------------|----------------------------------------------|
| Open Food Facts      | Barcode lookup for food products             |
| Open Products Facts  | Barcode lookup for non-food products         |

---

## Core Features

| Module               | Description                                                                  |
|----------------------|------------------------------------------------------------------------------|
| Authentication       | Phone OTP login via Firebase, session bridging to Supabase, JWT lifecycle     |
| Shop Management      | Shop profile, GST details, contact info; tenant boundary for data isolation  |
| Inventory            | Product catalogue with barcode scanning, external API lookups, stock tracking |
| Category Management  | Hierarchical product categorisation for organisation and filtering           |
| POS / Billing        | Cart management, barcode scan-to-cart, discounts, atomic sale completion      |
| Customer Management  | Customer directory with contact details and purchase history                 |
| Sales History        | Transaction records with line-item detail, filtering and search              |
| PDF Invoice          | Professional invoice generation with native share sheet integration          |
| Refund System        | Full and partial refunds with inventory restoration and audit trail          |
| Reports              | Sales summaries, revenue tracking, business metrics (expanding)              |
| Audit Logs           | Immutable record of all system events for compliance and transparency        |
| Dashboard            | Key metrics overview and quick-access navigation (under development)         |
| Staff Management     | Role-based access control and staff accounts (under development)             |
| Settings             | App configuration, shop preferences, user profile management                 |

---

## Architecture

StoreMate follows a layered architecture with a strict dependency rule: each layer may only depend on the layer directly below it.

**Presentation Layer** — Flutter widgets and screens. Renders state and captures user interaction. Contains no business logic.

**State Management Layer** — Riverpod providers. Manages UI state lifecycle and coordinates between presentation and data layers.

**Data Layer** — Repository and data source classes. Abstracts all communication with Supabase, external APIs and local storage.

**Backend Layer** — Supabase PostgreSQL, RPC functions, Edge Functions and Row Level Security. Owns all business logic, data integrity and access control.

The Flutter client is deliberately thin. All business rules, validation and transaction logic live in PostgreSQL. The client is a presentation layer only.

Feature modules are organised by domain under `lib/features/` (e.g., `inventory`, `sales`, `customer`), each following a consistent `data/`, `domain/`, `presentation/` structure. Shared utilities and configuration live in `lib/core/` and `lib/shared/`.

For detailed architecture documentation, see [03-System-Architecture.md](docs/03-System-Architecture.md).

---

## Supported Platforms

| Platform | Status    |
|----------|-----------|
| Android  | Supported |
| iOS      | Planned   |
| Web      | Planned   |

Android is the primary target platform, reflecting the device preferences of Indian small retail businesses.

---

## Offline Capability

StoreMate uses Hive for local key-value storage and offline caching. Critical product and transaction data is cached locally so that core POS operations can continue during network interruptions. Connectivity Plus monitors network state and triggers sync when connectivity is restored.

A full offline-first sync engine with conflict resolution is planned for Phase 4. The current implementation provides graceful degradation rather than complete offline independence.

---

## Security

Authentication uses a two-layer approach: Firebase Auth handles phone OTP verification, and a Supabase Edge Function (auth bridge) exchanges the Firebase token for a Supabase JWT. All subsequent API calls use the Supabase JWT for session management.

Data security is enforced at the database layer through PostgreSQL Row Level Security. Every table has RLS policies that isolate data by shop. The Flutter client is never trusted to enforce access boundaries. Service role keys are excluded from client-side code entirely.

For complete security architecture, see [03-System-Architecture.md](docs/03-System-Architecture.md) and [04-Database-Design.md](docs/04-Database-Design.md).

---

## Documentation Index

All project documentation lives in the `docs/` directory. Documents are numbered for reading order.

| Document                    | Purpose                                                                 |
|-----------------------------|-------------------------------------------------------------------------|
| [00-AI-INSTRUCTIONS.md](docs/00-AI-INSTRUCTIONS.md) | Mandatory rules for AI agents operating on this codebase |
| [01-PRD.md](docs/01-PRD.md) | Product Requirements Document: features, user stories, acceptance criteria |
| [02-TRD.md](docs/02-TRD.md) | Technical Requirements Document: system constraints, NFRs, integrations |
| [03-System-Architecture.md](docs/03-System-Architecture.md) | Architecture diagrams, component relationships, data flow |
| [04-Database-Design.md](docs/04-Database-Design.md) | Database schema, RLS policies, RPC functions, migrations |
| [05-API-Documentation.md](docs/05-API-Documentation.md) | Supabase API surface, Edge Function contracts, external APIs |
| [06-Business-Rules.md](docs/06-Business-Rules.md) | Business rules governing inventory, pricing, refunds, transactions |
| [07-UI-UX-Guidelines.md](docs/07-UI-UX-Guidelines.md) | Design system, component library, interaction patterns |
| [08-Coding-Standards.md](docs/08-Coding-Standards.md) | Dart/Flutter conventions, naming, file structure, review checklist |
| [09-Testing-Strategy.md](docs/09-Testing-Strategy.md) | Test pyramid, coverage targets, integration tests, CI pipeline |
| [10-Development-Roadmap.md](docs/10-Development-Roadmap.md) | Feature roadmap with milestones, dependencies, timelines |
| [11-Changelog.md](docs/11-Changelog.md) | Version-by-version record of changes, additions, deprecations |
| [12-Decision-Log.md](docs/12-Decision-Log.md) | Architectural Decision Records with context, options, rationale |
| [13-Backlog.md](docs/13-Backlog.md) | Prioritised backlog of features, improvements, technical debt |
| [14-Deployment.md](docs/14-Deployment.md) | Build, release and deployment procedures |
| [15-Contributing.md](docs/15-Contributing.md) | Contribution guidelines, branch strategy, versioning, PR process |
| [Engineering-Principles.md](docs/Engineering-Principles.md) | Core engineering principles governing all technical decisions |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.x (Dart 3.10+)
- Android Studio or VS Code with Flutter extensions
- Supabase CLI
- Firebase project with Authentication enabled
- A Supabase project with the StoreMate schema deployed

### Installation

```bash
git clone <repository-url>
cd StoreMate
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Configuration

1. Set up Firebase and place `google-services.json` in `android/app/`.
2. Configure Supabase credentials in the application config.
3. Deploy Supabase Edge Functions using the Supabase CLI.
4. Apply database migrations to your Supabase project.

### Running

```bash
flutter run
```

For detailed setup instructions, see [14-Deployment.md](docs/14-Deployment.md).

---

## Contributing

Contributions follow a structured process documented in [15-Contributing.md](docs/15-Contributing.md). The project uses a `main` / `develop` / `feature` branching model with Semantic Versioning. All merges require pull request review.

Before contributing, read:

1. This README
2. [00-AI-INSTRUCTIONS.md](docs/00-AI-INSTRUCTIONS.md)
3. [Engineering-Principles.md](docs/Engineering-Principles.md)
4. [08-Coding-Standards.md](docs/08-Coding-Standards.md)

---

## License

License terms are pending finalisation. This section will be updated prior to any public distribution.

---

## Maintainers

| Name              | Role               | Contact          |
|-------------------|--------------------| -----------------|
| Pratik Khose      | Project Owner      | TBD              |
