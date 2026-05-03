---
phase: 15
slug: sistema-gestione-magazzino-inventario
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-12
---

# Phase 15 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Flutter test (flutter_test) |
| **Config file** | pubspec.yaml (dependencies) |
| **Quick run command** | `flutter test test/features/inventory/` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/features/inventory/`
- **After every plan wave:** Run `flutter test`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 15-01-01 | 01 | 1 | D-01/02/03 | — | N/A | unit | `flutter test test/features/inventory/domain/` | ❌ W0 | ⬜ pending |
| 15-01-02 | 01 | 1 | D-08/09/10 | — | N/A | unit | `flutter test test/features/inventory/domain/` | ❌ W0 | ⬜ pending |
| 15-02-01 | 02 | 2 | D-01/02/03 | — | SQL parametrized queries | unit | `flutter test test/features/inventory/data/` | ❌ W0 | ⬜ pending |
| 15-02-02 | 02 | 2 | D-07/08/09 | — | SQL parametrized queries | unit | `flutter test test/features/inventory/data/` | ❌ W0 | ⬜ pending |
| 15-03-01 | 03 | 3 | D-04/05/06 | — | N/A | unit | `flutter test test/features/inventory/application/` | ❌ W0 | ⬜ pending |
| 15-03-02 | 03 | 3 | D-11/12/13 | — | N/A | widget | `flutter test test/features/inventory/presentation/` | ❌ W0 | ⬜ pending |
| 15-04-01 | 04 | 4 | D-04/05/06 | — | N/A | unit | `flutter test test/features/notifications/` | ❌ W0 | ⬜ pending |
| 15-04-02 | 04 | 4 | D-11/12/13 | — | N/A | widget | `flutter test test/features/inventory/presentation/` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/features/inventory/domain/entities/` — stubs for inventory entities
- [ ] `test/features/inventory/data/datasources/` — stubs for data sources
- [ ] `test/features/inventory/application/` — stubs for providers
- [ ] `test/features/inventory/presentation/` — stubs for widgets and pages

*Existing infrastructure covers test framework. New test directories needed for inventory feature.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Push notification appears on device | D-05 | Requires physical device notification delivery | Install APK, add item expiring in 3 days, verify notification |
| Bottom navigation shows 5 tabs | D-13 | Visual layout verification | Run app, count tabs, verify Magazzino tab present |
| Settings accessible from gear icon | D-12 | Navigation flow | Tap gear icon on Dashboard, verify Settings opens |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
