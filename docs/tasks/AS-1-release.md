# AS-1 — Privacy, App Store, archive, and TestFlight gate

## Goal

Reconcile runtime behavior, privacy evidence, Apple policy, metadata, signing, exact Release archive, and TestFlight validation before submission.

## Current Apple sources

Checked 2026-08-30:

- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Upcoming requirements: https://developer.apple.com/news/upcoming-requirements/
- Screenshot specifications: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/
- Privacy manifests: https://developer.apple.com/documentation/bundleresources/privacy-manifest-files
- Required-reason APIs: https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api
- Account deletion: https://developer.apple.com/support/offering-account-deletion-in-your-app/

## Repo-owned acceptance

- Valid bundled `PrivacyInfo.xcprivacy` declares no tracking, app-linked functionality data, and `UserDefaults` reason `CA92.1`.
- No ATT prompt, tracking domain, third-party SDK, social login, digital-goods/IAP path, unsupported entitlement, or background mode.
- Email/password auth and in-app asynchronous account-deletion initiation remain intact.
- Travel purchase is a real-world service under Guideline 3.1.3(e), not StoreKit digital content.
- CI uses Xcode 26.6/iOS 26 SDK and proves manifest inclusion in built app.

## External release blockers

- Publish verified live privacy-policy and terms URLs; add easily accessible in-app links and App Store Connect privacy-policy metadata. No working product URLs were discoverable on 2026-08-30.
- Reconcile App Store privacy labels with manifest/runtime/backend retention and legal policy.
- Supply working demo credentials plus review notes for auth, booking, payment-proof, ticketing, and asynchronous deletion.
- Capture 1–10 current 6.9-inch iPhone screenshots; capture 13-inch iPad set if iPad remains supported.
- Complete updated age-rating questions in App Store Connect.
- Produce signed Release archive with distribution identity, generate Xcode privacy report, validate archive, upload exact build, then complete internal TestFlight cold-launch/full-flow/device accessibility/motion/network checks.

## Evidence required before completion

- Latest PR-head CI green.
- Links to live policy/terms and completed App Store Connect privacy/metadata records.
- Exact archive build number/commit, validation result, privacy report, signing/entitlement dump.
- TestFlight build link plus device matrix and completed flow results.

AS-1 remains active until every external blocker has evidence. Never mark complete from source/CI alone.
