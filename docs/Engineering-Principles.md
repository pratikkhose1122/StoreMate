# Engineering Principles

| Field        | Value              |
|--------------|--------------------|
| Version      | 1.0                |
| Status       | Locked             |
| Owner        | Project Owner      |
| Last Updated | 2026-09-09         |

> [!IMPORTANT]
> This document is considered stable. Changes require architectural review and an entry in the Decision Log.

These principles govern all technical decisions in StoreMate. Any change that conflicts with these principles requires an explicit entry in the [Decision Log](12-Decision-Log.md) with documented justification.

---

## Single Source of Truth

Every data entity has exactly one authoritative source. For persistent data, the source of truth is the Supabase PostgreSQL database. For UI state, it is the Riverpod provider tree. Duplication of truth across layers is prohibited.

---

## Business Logic Belongs in Supabase

All business rules, data validation, transaction integrity checks and access control logic must be implemented in PostgreSQL (RPC functions, triggers, constraints) or Supabase Edge Functions. The Flutter client is a presentation and interaction layer only.

---

## Flutter Stays Thin

The Flutter application is responsible for rendering UI, capturing user input, managing local navigation state and calling Supabase. It must not contain business rule evaluation, complex data transformations or security enforcement logic.

---

## Atomic Transactions

Operations that span multiple tables or have side effects (sale completion, refund processing, inventory adjustment) must execute as atomic database transactions. Partial state mutations are not acceptable.

---

## Security First

Row Level Security is mandatory on every table. No table may be exposed without RLS policies. The client must never be trusted to enforce access control. All security boundaries are enforced at the database layer.

---

## Performance

POS-critical paths must complete in under one second on mid-range Android devices over typical Indian mobile networks (3G/4G). Non-critical operations should complete in under three seconds. Performance budgets are non-negotiable.

---

## Maintainability

Code must be readable by a developer or AI agent unfamiliar with the project. This means clear naming, small focused functions, comprehensive documentation and adherence to established patterns. Clever code is prohibited.

---

## Scalability

Architecture decisions must account for growth from a single store to hundreds of stores without requiring structural changes. Data isolation, query patterns and caching strategies must be designed for multi-tenant scale.

---

## Readable Code

All code must read like well-written prose. Variable and function names must be descriptive and unambiguous. Abbreviations are discouraged unless universally understood (e.g., `id`, `url`).

---

## No Dead Code

Unused code, commented-out blocks, unreachable branches and obsolete files must be removed immediately. Dead code creates confusion, increases maintenance burden and misleads future contributors.

---

## Documentation First

No feature is considered complete until its documentation is written. Documentation is not an afterthought; it is a deliverable equal in importance to the code itself.

---

## Simplicity Over Cleverness

Prefer simple, explicit implementations over clever abstractions. Avoid unnecessary layers, premature optimisation, or generic frameworks unless there is a demonstrated need. Readable code is preferred over reusable code when the abstraction provides little practical benefit.

---

## Consistency Over Convenience

Prefer consistency with the existing architecture over short-term implementation convenience. A consistent codebase is easier to maintain than a collection of individually optimised solutions.

---

## Additive Database Changes

Database schema changes should be additive whenever possible. Prefer adding columns, tables and indexes over dropping or renaming existing structures. Destructive changes increase migration risk, break backward compatibility and complicate rollbacks. When removal is necessary, deprecate first and remove in a subsequent major release.
