# <ID>: <observable outcome>

## Ownership

- PARITY row: `<ID>`
- Branch: `parity/<id>-<slug>`
- One agent owns branch through green CI.
- No overlap with other active rows.

## Outcome

One user-visible or contract-visible behavior. State exact before/after observation.

## Truth sources — read completely

- Android files: exact absolute paths.
- Backend files/tests: exact absolute paths, when networked.
- Mockup/anatomy boards: exact paths, when UI.
- ADR/PORTING sections controlling decisions.

## Required skills

List only task-relevant skills from AGENTS routing. Include supporting references required for touched APIs.

## Interface and invariants

- State owner:
- Inputs/outputs:
- Dependencies/Adapters:
- Valid transitions/order:
- Cancellation/error modes:
- Accessibility/privacy/security invariants:

## Scope

Files allowed to change. New files named explicitly.

## Non-scope

Adjacent behavior forbidden in this PR. No opportunistic cleanup.

## TDD proof

### RED

- Add smallest behavior/contract/state test first.
- Run focused command; paste expected failure summary and reason.
- Test must fail because behavior missing, not setup typo.

### GREEN

- Minimum implementation only.
- Run focused test, then full unit suite.

### REFACTOR

- Only after green. Preserve behavior; rerun focused + full suite.

## CI gates

- Generate project: `xcodegen generate`.
- Build: exact `xcodebuild build` command.
- Unit/contract: exact `xcodebuild test` command.
- UI row: simulator screenshot/interaction evidence.
- CRITICAL row: archive/review evidence named in PARITY/AGENTS.

## Adversarial review

Fresh context compares implementation against every truth source. Record mismatches. Fix or log known deviation; repeated mistake updates rulebook.

## PR contract

- Title: `PARITY <ID>: <outcome>`.
- Body links task file, RED evidence, GREEN evidence, parity review, risks.
- Agent pushes, watches latest-SHA checks, reads full failing log, fixes root cause, pushes same branch, repeats.
- Max three same-root CI failures. Third recurrence -> mark blocked with logs/root-cause evidence; never weaken/delete test.
- Merge only green latest SHA, required review complete, PARITY/PROGRESS updated.

## Done

Checklist containing exact observable acceptance criteria. No unchecked item when row becomes `☑`.
