# P0-2: PLAN/ARCHIVE stateless agent workflow

## Ownership

- Branch: `parity/p0-2-parallel-agent-contract`
- Expected base: merged P0-1 on `main`
- Dependencies: P0-1
- Coordinator task; no concurrent feature work until merged.

## Outcome

Fresh agents find every task in `PLAN.md`, execute one self-contained packet without chat history, and rely on PR/CI for live execution evidence. `ARCHIVE.md` contains only merged, latest-SHA-green results.

## Scope

- Add root `PLAN.md` and `ARCHIVE.md`.
- Migrate phase gates and complete task list from `docs/PHASES.md` and `docs/PARITY.md`.
- Migrate verified completion evidence from `docs/PROGRESS.md`.
- Update `AGENTS.md` and `docs/TASK-TEMPLATE.md`.
- Delete superseded phase/parity/progress ledgers.

## Non-scope

No scheduler, issue bot, machine task index, per-task progress ledger, Swift feature, Android/backend change, or new dependency.

## Invariants

- `PLAN.md` is compact roadmap/index, not full task specification.
- Only coordinator edits `PLAN.md` and `ARCHIVE.md`.
- Agent reads `AGENTS.md`, assigned packet, listed truth sources, and touched code—not entire archive.
- `[x]` means merged plus latest-SHA CI green.
- Active/queued tasks never appear as completed archive entries.
- Each task packet defines exact scope, ownership, skills, tests, acceptance, and CI loop.

## Verification

- `rg` finds no live references to `docs/PHASES.md`, `docs/PARITY.md`, `docs/PROGRESS.md`, or per-task progress files.
- Every roadmap task from old PARITY ledger exists in `PLAN.md` exactly once.
- Every checked task has matching `ARCHIVE.md` evidence.
- `git diff --check` passes.
- PR latest-SHA iOS CI passes before merge.

## Done

- [x] Canonical ledgers created and old ledgers removed.
- [x] Agent session/dispatch rules updated.
- [x] Task template is self-contained and coordinator-safe.
- [x] Roadmap and completed evidence migrated without loss.
- [ ] Latest-SHA CI green.
