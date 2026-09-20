# AI Agent Instructions

| Field        | Value              |
|--------------|--------------------|
| Version      | 1.0                |
| Status       | Locked             |
| Owner        | Project Owner      |
| Last Updated | 2026-09-09         |

> [!IMPORTANT]
> This document is considered stable. Changes require architectural review and an entry in the Decision Log.

This document is mandatory reading for any AI agent, LLM, coding assistant or autonomous agent operating on the StoreMate codebase. It must be read before making any change, generating any code, or proposing any architectural decision.

Violations of these rules will produce incorrect, insecure or architecturally inconsistent output.

---

## Document Reading Order

Before making any change, read these documents in this exact order:

1. `README.md` — Project overview and entry point.
2. `docs/00-AI-INSTRUCTIONS.md` — This document. Mandatory constraints.
3. `docs/Engineering-Principles.md` — Core principles governing all decisions.
4. `docs/01-PRD.md` — Product requirements, user stories, acceptance criteria.
5. `docs/02-TRD.md` — Technical requirements, system constraints, NFRs.
6. `docs/03-System-Architecture.md` — Architecture, component relationships, data flow.
7. `docs/04-Database-Design.md` — Schema, RLS policies, RPC functions.
8. `docs/06-Business-Rules.md` — Business rules governing all operations.
9. `docs/12-Decision-Log.md` — Architectural Decision Records.

Do not skip any document. Context from earlier documents informs constraints in later documents.

---

## Documentation Precedence

When multiple documents overlap, resolve conflicts using the following precedence (highest to lowest):

1. Decision Log (`12-Decision-Log.md`)
2. Business Rules (`06-Business-Rules.md`)
3. System Architecture (`03-System-Architecture.md`)
4. Database Design (`04-Database-Design.md`)
5. TRD (`02-TRD.md`)
6. PRD (`01-PRD.md`)
7. `README.md`

If a conflict cannot be resolved using this order, stop and request human review.

---

## Project Scope

StoreMate is a retail Point of Sale (POS), Inventory Management, and Business Management system for Indian SMEs.

AI agents must not introduce features that significantly change the product direction (ERP, CRM, HRM, Accounting Suite, E-commerce Platform, etc.) unless those features already exist in the PRD, Roadmap, or Backlog.

---

## Mandatory Constraints

Follow every principle defined in `Engineering-Principles.md`. Principles are not restated here to avoid duplication and drift.

### Architecture

- Never make architectural decisions without first consulting `12-Decision-Log.md` and `03-System-Architecture.md`. If the decision is not covered, flag it for human review.

### Business Rules

- Never violate business rules defined in `06-Business-Rules.md`. Business rules are non-negotiable regardless of implementation convenience.
- Never create features outside the documented roadmap. If a requested feature is not in `10-Development-Roadmap.md` or `13-Backlog.md`, flag it for product review before implementation.

### Security

- Never bypass Supabase security. All data access must go through RLS-protected endpoints.
- Service role keys must never be used in client-side code.
- Disabling RLS for convenience is strictly prohibited.
- Never expose internal IDs, tokens or credentials in client-side logs or error messages.

### Code Quality

- Never duplicate functionality. Reuse existing services, repositories, providers, widgets and models whenever practical. Do not create parallel implementations of existing functionality.
- New packages should only be introduced if they provide substantial value that cannot reasonably be achieved with existing project dependencies, the Flutter SDK, or the Dart standard library. The justification must be documented in the Decision Log.
- Never commit code without tests for any new business logic or data layer functionality.
- Never leave dead code. Unused code, commented-out blocks, unreachable branches and obsolete files must be removed.

### Database

- Never modify database schema without creating a migration and updating `04-Database-Design.md`.
- Never create tables without RLS policies.
- Never use raw SQL in the Flutter client. All database operations go through Supabase client methods or RPC calls.

### Database Migration Rules

Every schema change must include:

- Migration SQL.
- Updated Database Design documentation (`04-Database-Design.md`).
- Updated RPC documentation (`05-API-Documentation.md`) if affected.
- Backward compatibility considerations.

### Documentation

- Never make a change that contradicts existing documentation without flagging the discrepancy for human review.
- Never consider a feature complete until its documentation is updated.
- Update `11-Changelog.md` when any user-facing behaviour changes.

---

## Backward Compatibility

Do not introduce breaking API, database, or model changes unless explicitly approved.

When modifying an existing feature:

- Preserve existing behaviour unless intentionally changing it.
- Migrate existing data when required.
- Document all breaking changes in the Decision Log and Changelog.

---

## Performance Budget

The following operations are considered performance-critical:

- Barcode Scan
- Product Search
- Cart Updates
- Checkout
- Invoice Opening

These workflows should complete within one second on supported Android devices.

Avoid unnecessary rebuilds, excessive database calls, or redundant API requests.

---

## External APIs

External APIs are optional enrichment sources.

Failure of an external API must never prevent the core POS workflow.

If an external lookup fails, the application must fall through this cascade:

1. Local Database
2. Cache
3. External APIs
4. Manual Entry

The application must always remain usable.

---

## Offline Behaviour

Core retail workflows should continue whenever possible during network interruptions.

If a feature cannot function offline:

- Preserve user input.
- Show a clear explanation.
- Retry safely after connectivity returns.

Never discard user-entered data because of connectivity loss.

---

## Before Creating New Code

Before creating any:

- Provider
- Repository
- Service
- Widget
- Model
- RPC
- Table
- Migration

Search the project for an existing implementation.

Prefer extending existing components over creating parallel implementations.

---

## Missing Information

If required information is missing:

- Do not guess.
- Do not invent database fields.
- Do not invent API contracts.
- Do not invent UI behaviour.

Instead:

1. Explain what information is missing.
2. Present available options.
3. Wait for approval if necessary.

---

## When Documentation Is Silent

If a requested implementation is not covered by any project document:

1. Search the existing codebase for established patterns.
2. Search the Decision Log for prior related decisions.
3. Present options and trade-offs.
4. Wait for approval before introducing new patterns or architecture.

---

## Source of Truth

Approved project documentation is the primary source of truth.

If documentation conflicts with the implementation:

1. Flag the discrepancy.
2. Do not silently change either.
3. Request clarification before proceeding.

---

## Decision Making

When facing a decision not covered by existing documentation:

1. Check `12-Decision-Log.md` for prior decisions on related topics.
2. Check `Engineering-Principles.md` for guiding principles.
3. If neither provides a clear answer, present the options with trade-offs and recommend an approach. Do not make the decision unilaterally.
4. Document the decision in `12-Decision-Log.md` once approved.

Architectural changes require an ADR (Architectural Decision Record). The ADR must contain:

- **Context** — Why this decision is needed.
- **Options** — Alternatives considered.
- **Decision** — What was chosen.
- **Consequences** — Trade-offs and impact.

---

## Required Implementation Workflow

For every feature or bug fix:

1. Read the required documentation.
2. Search for an existing implementation.
3. Identify affected modules.
4. Verify architecture compliance.
5. Implement the change.
6. Add or update tests.
7. Update documentation.
8. Update Changelog if user-visible.

---

## Code Generation Rules

- Follow the conventions in `08-Coding-Standards.md` exactly.
- Use Riverpod for all state management. No `setState`, no `ChangeNotifier`.
- Use GoRouter for all navigation. No imperative `Navigator.push` calls.
- Use Freezed for all domain models. No manual model classes.
- Place all new feature code under `lib/features/<feature_name>/` with `data/`, `domain/` and `presentation/` subdirectories.
- Shared utilities go in `lib/core/`. Shared widgets go in `lib/shared/widgets/`.
- Name files in `snake_case`, classes in `PascalCase`, variables and functions in `camelCase`.
- Document the "why", not the "what". Prefer self-documenting code over inline comments.

---

## Error Handling

- All Supabase calls must be wrapped in try-catch with user-facing error messages.
- Silent failures are prohibited. Every error must be logged and surfaced appropriately.
- Network errors must be handled gracefully with retry or offline fallback behaviour.

---

## Testing Requirements

- All new business logic must have unit tests.
- All new data layer code must have integration tests.
- All new UI flows should have widget tests for critical paths.
- Tests must be independent and deterministic. No tests that depend on external services or network.

---

## Definition of Done

A feature is complete only when:

- Implementation is complete.
- Tests pass.
- Documentation is updated.
- Changelog updated (if user-facing).
- Database migrations are included (if applicable).
- Existing functionality remains unaffected.

---

## Deprecation

Deprecated code should:

- Remain functional until the replacement is stable.
- Be clearly documented as deprecated.
- Include a migration path for consumers.
- Be removed in the next major release.

---

## Feature Flags

Large unfinished features should be hidden behind feature flags rather than partially exposed to users. A feature that is not ready for production use must not be reachable through the normal UI.
