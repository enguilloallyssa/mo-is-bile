# SARI Rider — Figma UI adaptation

This package is an **UI-only starting point**, based on the screenshot and the supplied `rider_hero.dart` Flutter source. It retains the previously shared `RiderHome` public constructor and the callbacks to the host Flutter app. It does **not** alter Laravel, your API client, database, authentication, permissions, or server routes.

## Files included

- `lib/rider/rider_home.dart` — new responsive dashboard with Figma-style hero, 4 KPI cards, floating navigation, refresh, and existing callback wiring.
- `lib/rider/widgets/rider_hero.dart` — the supplied animated hero, adjusted to wire the 3 header buttons through callbacks.
- `lib/rider/widgets/rider_figma_components.dart` — shared cards, section headings, buttons, navigation, and a reusable page shell.

## Safe application to your Flutter app

1. Create a Git branch and commit/backup your current Rider UI files before replacing anything. Do **not** paste the Figma sample `main()` over your real application entry point: that would bypass the existing authentication/navigation.
2. From the ZIP, copy these three files to the same paths in your Flutter app. `rider_home.dart` expects your existing models at `lib/rider/models/rider_delivery_model.dart` and `lib/rider/models/rider_profile_model.dart`. The previous code you provided used those imports; if your real paths differ, adapt the imports.
3. Leave existing `main.dart`, API client, models, controllers, backend, and routes unchanged.
4. Run `flutter analyze`, then test with your API and a real Rider account. Dart and Flutter were not available to compile this bundle in the creation environment, so this is **not** a verified clean build against your app.
5. Verify your `dashboardSummary` field names. The UI reads common aliases (e.g., `active_pickups`, `active_deliveries`, `last_mile_batches`, `completed_today`). If your API uses other keys, add them to the `_summaryInt(...)` alias lists in `rider_home.dart`. Never replace actual data with hardcoded zero values.

## Connect notification modal

`RiderHome` now accepts an **optional** `onOpenNotifications` callback. Pass your existing notification-page or modal action if available:

```dart
RiderHome(
  // Keep all required arguments you already supply today...
  onOpenNotifications: () => openYourExistingNotifications(),
)
```

If you do not supply the callback, the bell opens an informative sheet instead of claiming the API is connected. The current code does not implement background polling or notification sound.

## Make the other pages match — without replacing working APIs

Because the full Flutter Rider folder was not provided, it would be unsafe to overwrite the live Jobs, Deliveries, Earnings, and Account screens. Use the shared components to style those screen bodies **while retaining their current data-loading and action code**. For example, when refactoring your existing Jobs screen, wrap its existing content with the new visual shell:

```dart
return RiderFigmaPage(
  title: 'Jobs',
  subtitle: 'Assignments and pickup requests',
  icon: Icons.assignment_outlined,
  selectedTab: 1,
  onTabChanged: yourExistingTabChangeCallback,
  child: yourExistingJobsBody, // The body of the existing Jobs screen, not another Scaffold
);
```

Set `selectedTab` to 2 for Deliveries, 3 for Earnings, 4 for Account. Keep the page's actual state, actions and APIs, and reuse `RiderEyebrow`, `RiderSectionHeading`, `RiderActionCard`, `RiderStatCard` to style its content. The `RiderFigmaPage` component is provided for this purpose; **the ZIP does not claim that the other existing pages are already modified**.

If your app already owns a 5-tab navigation router, keep passing `onTabChanged` to RiderHome. That router continues to open the original API-backed Jobs/Deliveries/Earnings/Account pages. If you do not supply this callback, the new home provides simplified, clearly labeled local fallback tabs instead. The fallback tabs are **not** a substitute for the app's full delivery/scan/proof-of-delivery workflows.

## Navigation mapping

- 0 = Home
- 1 = Jobs
- 2 = Deliveries (center orange floating button)
- 3 = Earnings
- 4 = Account

## Design tokens

- Hero: black, bronze, gold with soft fade to `#EEF0EE`.
- Gold: `#C9A24B`; light gold `#F3DFA2`.
- Text: `#14211C`; white rounded cards; 24px card corners.
- Pastel accents: amber for pickups, sky-blue for deliveries, lavender for last-mile, mint for completed.
- Bottom navigation: floating white pill, highlighted Home and raised amber-orange Deliveries action.

## Copy in PowerShell (run from your Flutter project root)

```powershell
# Place SARI_Rider_Figma_UI.zip in your Flutter project root first
Expand-Archive -Path .\SARI_Rider_Figma_UI.zip -DestinationPath .\sari_rider_figma -Force

git switch -c ui/rider-figma
New-Item -ItemType Directory -Force lib\rider\widgets | Out-Null
Copy-Item .\sari_rider_figma\lib\rider\rider_home.dart .\lib\rider\rider_home.dart -Force
Copy-Item .\sari_rider_figma\lib\rider\widgets\rider_hero.dart .\lib\rider\widgets\rider_hero.dart -Force
Copy-Item .\sari_rider_figma\lib\rider\widgets\rider_figma_components.dart .\lib\rider\widgets\rider_figma_components.dart -Force
flutter analyze
flutter run
```

Run `git status` first and use a different branch name if it already exists. Do not continue the copy commands if your working tree contains uncommitted edits you want to retain.
