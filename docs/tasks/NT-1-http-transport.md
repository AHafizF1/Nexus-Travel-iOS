# NT-1: App configuration and shared HTTP transport

## Ownership and truth

- Branch `codex/nt-1-http-transport`; Phase 2 merged.
- Own `Sources/Core/Network/{AppConfiguration,HTTPRequest,HTTPTransport}.swift` and matching `Tests/Core/Network/` tests; migrate existing `Tests/Core/AppConfigurationTests.swift` into owned test path if needed.
- Everything else read-only. Coordinator owns PLAN/ARCHIVE/packet/push/PR/CI.
- Read backend routes/controllers/e2e tests first, then Android `core/network/*` and remote adapters. Backend is network truth. Production origin `https://api.travelwithnexus.com`; mobile prefix `/api/v1/mobile`; health `/api/v1/health`; auth `/api/auth/*` outside mobile.
- Use ponytail, write-swift, swift-expert, Swift API guidelines, TDD, architecture/code-structure/DRY/swift-architecture, swift-concurrency-pro. No UI/copy/animation.

## Minimum contract

- Keep `AppConfiguration` single source for origin/mobile/health. Add safe URL construction for root paths, mobile-relative paths, and absolute signed-upload URLs. Reject malformed/non-HTTP(S) absolute URLs and traversal; never duplicate prefix.
- `HTTPMethod`: GET/POST/PUT/PATCH/DELETE.
- `HTTPRequest`: target, method, headers, optional body, authorization (`none` or bearer token), timeout. Default JSON `Accept`; set JSON content type only when body exists unless caller overrides. Absolute signed-upload request must remain bearer-free when authorization is none and preserve every required header.
- `HTTPResponse`: data, status code, normalized headers.
- `HTTPTransport.send(_:) async throws -> HTTPResponse`; native URLSession adapter behind minimal data-loading seam because production and deterministic fake both exist. URLSession async API propagates cancellation; never convert `CancellationError`/cancelled URL error into user-visible transport failure.
- `HTTPTransportError`: invalidRequest; timedOut; networkUnavailable; nonHTTPResponse. HTTP statuses are successful transport responses for repository mapping—never classify 4xx/5xx globally. Decoding belongs repository/codec layer, not transport.
- Timeout mapping includes `NSURLErrorTimedOut`; network includes not connected, cannot find/connect host, DNS, connection lost, international roaming/data-not-allowed. Unknown underlying errors propagate unchanged.
- Attach exact `Authorization: Bearer <token>` only for bearer authorization. Reject blank bearer token as invalid request. Caller header cannot override Authorization. Never log token/body/response. Use `Logger` with private correlation UUID plus method/status/duration class only.
- Value types Sendable. No actor/task/detached work; URLSession already suspends I/O. No retries—repositories/actions own retry policy and stable idempotency keys.

## TDD

Commit tests-only RED, then minimum GREEN. Deterministic fake loader; no sleeps/live network/global URLProtocol state.

Cover exact production/mobile/health/auth/absolute URLs; slash normalization and traversal/unsupported scheme rejection; method/body/default/override headers; bearer attach/blank/override prevention; required signed-upload headers without bearer; 2xx/4xx/5xx returned unchanged; timeout/network classifications; cancellation remains CancellationError; non-HTTP response; unknown error identity/type propagation. Verify fake receives request timeout and URLRequest exactly.

Exclude endpoint route catalogs, DTOs/decoding, auth/session/Keychain, repositories, retries/backoff, refresh tokens, caches, reachability monitor, upload orchestration, idempotency generation, certificate pinning, UI, third-party packages.
