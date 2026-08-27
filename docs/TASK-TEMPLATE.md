# <ID>: <observable outcome>

## Ownership

- PLAN task: `<ID>`
- Branch: `codex/<id>-<slug>`
- GitHub issue:
- Expected base SHA:
- Wave:
- Merged dependencies:
- One agent owns branch through green CI.
- No overlap with other active tasks.

## Exclusive ownership

- Allowed production paths:
- Allowed test paths:
- Coordinator-owned files — do not edit:
  - `PLAN.md`
  - `ARCHIVE.md`
- Shared Interfaces treated as read-only:

## Outcome

One user-visible or contract-visible behavior. State exact before/after observation.

## Truth sources — read completely

- Android files: exact absolute paths.
- Backend files/tests: exact absolute paths, when networked.
- Android component/screen Kotlin: exact absolute paths, when UI.
- ADR/PORTING sections controlling decisions.
- Excluded: all legacy PNGs, mockups, boards, PDFs, DOCX files, and handbooks.

## Required skills

List only task-relevant skills from AGENTS routing. Include supporting references required for touched APIs.

## Interface and invariants

- State owner:
- Inputs/outputs:
- Dependencies/Adapters: exact role-based initializer/property names, concrete-vs-protocol reason, composition-root owner.
- Valid transitions/order:
- Cancellation/error modes:
- Accessibility/privacy/security invariants:

## Scope

Files allowed to change. New files named explicitly.

## Non-scope

Adjacent behavior forbidden in this PR. No opportunistic cleanup.

## TDD proof

## Acceptance matrix

| Scenario | Input | Expected state/output | Evidence |
|---|---|---|---|
| Happy | | | |
| Loading | | | |
| Empty | | | |
| Failure | | | |
| Cancellation | | | |
| Offline | | | |

### RED

- Add smallest behavior/contract/state test first.
- Run focused command locally when platform supports it; paste expected failure summary and reason.
- Test must fail because behavior missing, not setup typo.
- If Windows cannot compile touched Apple APIs, commit test first and record expected missing-symbol/behavior reason. Do not open RED-only PR or consume macOS CI solely for RED proof.

### GREEN

- Minimum implementation only.
- Run focused test, then full unit suite.

### REFACTOR

- Only after green. Preserve behavior; rerun focused + full suite.

## CI gates

- Generate project: `xcodegen generate`.
- Build: exact `xcodebuild build` command.
- Unit/contract: exact `xcodebuild test` command.
- UI task: simulator screenshot/interaction evidence.
- CRITICAL task: archive/review evidence named in PLAN/AGENTS.

## Adversarial review

Fresh context compares implementation against every truth source. Record mismatches. Fix or log known deviation; repeated mistake updates rulebook.

## PR contract

- Title: `PARITY <ID>: <outcome>`.
- Body links task file, RED evidence, GREEN evidence, parity review, risks.
- Agent keeps packet/RED/implementation local until feature is complete, then pushes and opens PR once. Agent watches latest-SHA checks, reads full failing log, fixes root cause, pushes same branch, repeats.
- Max three same-root CI failures. Third recurrence -> mark blocked with logs/root-cause evidence; never weaken/delete test.
- Merge only when latest-SHA CI is green and every required review/conversation gate passes.
- Feature agent never marks PLAN complete or appends ARCHIVE; coordinator does both after merge.

## Done

Checklist containing exact observable acceptance criteria. No unchecked item when coordinator marks PLAN `[x]` after merge.
