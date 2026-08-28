# AU-2: Keychain session store

## Ownership and truth

- Branch `codex/au-2-keychain-session`; requires AU-1.
- Own `Sources/Domain/Auth/AuthSessionStore.swift`, `Sources/Data/Auth/Storage/{KeychainAuthSessionStore,SecurityKeychainClient}.swift`, `Sources/Data/Auth/AuthTokenProvider.swift`, and matching tests.
- Existing Auth models, PLAN/ARCHIVE/packet/project config read-only during feature implementation.
- Read Android AuthSessionStore, DataStore/InMemory stores, token provider, repository session lifecycle, ADR-0005, AGENTS/PORTING/CONVENTIONS. Apple Keychain mechanics replace insecure Android preference mechanics.
- Use ponytail, write-swift, swift-expert, Swift API guidelines, TDD, architecture/code-structure/DRY/swift-architecture, swift-concurrency-pro. No UI/network.

## Contract

- `StoredAuthSession(session: AuthSession)` and `AuthSessionStore: Sendable` async `read/write/clear`.
- `KeychainAuthSessionStore` uses one generic-password item: service `com.nexustravel.NexusTravel.auth`, account `session`. Store full session payload, including tokens, only in Keychain—never UserDefaults/files/logs.
- Private Codable payload mirrors AuthSession/User/tokens without changing AU-1 model conformances. Decoder ignores additive fields. Missing required/corrupt payload: delete item and return nil, matching Android self-heal. Missing item returns nil. Write replaces existing item atomically. Clear treats missing as success.
- Security item accessibility: `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`; no synchronizable/iCloud migration. Return data only. Never log secrets.
- Minimal async `KeychainClient` seam exists because Security adapter and deterministic fake both exist. Map unexpected OSStatus into typed `KeychainError(status:)`; preserve old value when update fails.
- `AuthTokenProvider(sessionStore:)` returns current optional access token only. No refresh-token behavior/API.
- Storage does not decide expiry/usability and does not call backend; AU-3 repository owns those rules.

## TDD

Commit tests-only RED then minimum GREEN. Fake client actor; no real shared Keychain state or timing.

Cover missing read; full optional-rich round trip; nil avatar/tokens/refresh; overwrite; clear/missing clear; corrupt payload self-clears; client read/write/delete failure propagation except corrupt self-heal; token provider present/missing. Verify service/account/accessibility/synchronizable/value-data query contract at Security adapter boundary without exposing secret content in diagnostics.

Exclude repository/API/DTO/mappers, session expiry, remote validation, sign-in/out, refresh, ViewModel/UI, UserDefaults/files, biometrics/access-control prompts, shared web credentials, iCloud sync, migrations, networking.
