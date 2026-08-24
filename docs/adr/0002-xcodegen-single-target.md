# ADR-0002: XcodeGen single application target

- Status: Accepted
- Date: 2026-08-24

## Decision

Use pinned XcodeGen 2.44.1 to generate one iOS application target plus test target from `project.yml`. Never edit generated `.xcodeproj`.

## Reason

Text config is reviewable on Windows and reproducible in macOS CI. Single target avoids premature package/module overhead.

## Consequences

- XcodeGen is build tooling, not shipped runtime dependency.
- Version changes require ADR amendment and green bootstrap PR.
