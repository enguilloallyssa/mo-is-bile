# SARI Logistics Mobile — V1 UI

Source baseline: `mo-is-bile-main(3).zip` (latest Flutter archive supplied by user).

## How to install

Extract this ZIP **into the Flutter project's `lib/` folder** so the resulting path is `lib/logistics/logistics_shell.dart`. Replace the previous placeholder `logistics_shell.dart`. No edits to `main.dart`, Buyer, Rider, registration, or other shared files are needed. The existing `/logistics` named route already imports `LogisticsShell`.

## Included

- `logistics_shell.dart` — five-tab navigation, right-side tools drawer, background authenticated `/me` refresh, real logout
- `logistics_home.dart` — operational home, quick links, counts explicitly unavailable until API
- `logistics_operations.dart` — operational queues and shortcuts
- `logistics_scanner.dart` — **working on-device QR/barcode reader and manual input** using existing `mobile_scanner` dependency; copy and rescan
- `logistics_transfers.dart` — incoming/outgoing/history views (no fake manifests)
- `logistics_queues.dart` — incoming parcels, sorting, pickup verification and last-mile workflow UI (no fake state updates)
- `logistics_monitoring.dart`, `logistics_notifications.dart`, `logistics_messages.dart` — read-only scaffolds for future APIs
- `logistics_account.dart` — reads account summary via existing `/api/v1/me` when available, refresh and secure logout
- `services/logistics_session.dart` — conservative account payload parsing
- `widgets/logistics_ui.dart` — independent theme/widgets, no changes to Buyer/Rider components

## Current functionality and safety

**Connected now:** shared authenticated `/me` and `/logout`; scanning locally via device camera, manual QR/barcode entry, clipboard copy. There is **no parcel verification API call**, no parcel receipt, sort, dispatch, transfer receipt, assignment, or COD mutation. All counts show `—` rather than fabricated zero values. Successful scanning does NOT mean the parcel is valid or belongs to this hub. Local captured content is not persisted and leaves the screen when navigating away.

**Later Laravel API phase:** add authorized Logistics endpoints for dashboard, scanner lookup (including hub/operator scope), incoming intake, sorting, manifests, origin dispatch, destination receive, pickup verification, last-mile assignment, notifications/messages, monitoring, etc. Backend must authorize every state transition; no browser-session routes used.

## Registration

`lib/screen/logistics_register_screen.dart` and changes to `lib/screen/register_screen.dart` are separate from this folder and are **not included/overwritten** by this ZIP. Keep the Logistics registration code already added manually in VS Code. Mobile Logistics registration still needs a server endpoint and OTP flow to submit data.

## Test

```sh
flutter pub get
flutter analyze
flutter run
```

Open a Logistics account, inspect all five tabs, test Scan (camera permission needed), test manual entry, open secondary pages from right drawer, and verify logout.
