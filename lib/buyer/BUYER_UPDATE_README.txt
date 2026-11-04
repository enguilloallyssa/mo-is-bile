SARI Buyer Mobile – Account Settings Revamp

REPLACE ONLY: lib/buyer/
The ZIP contains the complete Buyer module.

Changed from previous version:
- Removed global left-side hamburger from Home, Shop, and all other Buyer screens.
- Account page shows a settings/tune icon on the upper-right.
- Tapping it opens an Account-only RIGHT-SIDE drawer.
- Only secondary items inside: Messages, Shipping & Tracking, Log out.
- Logout calls the existing authenticated Laravel API when available, then clears on-device secure token keys.
- Account page has refreshed hero layout, card treatment, and extra shortcuts.
- Original Buyer API/service logic, address and form workflows preserved.

Notes: Flutter SDK not installed in authoring environment. Run `flutter analyze` after replacement.
Server-dependent features require Laravel API to be online for end-to-end verification.
