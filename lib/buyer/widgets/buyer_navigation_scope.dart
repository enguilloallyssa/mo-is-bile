import 'package:flutter/widgets.dart';

/// Context action for Buyer Account settings. No menu on Home/Shop.
class BuyerNavigationScope extends InheritedWidget {
  final VoidCallback openSettings;

  const BuyerNavigationScope({
    super.key,
    required this.openSettings,
    required super.child,
  });

  static BuyerNavigationScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BuyerNavigationScope>();

  @override
  bool updateShouldNotify(BuyerNavigationScope oldWidget) =>
      openSettings != oldWidget.openSettings;
}
