import 'package:flutter/material.dart';

import 'package:petvita/core/constants/app_routes.dart';
import 'package:petvita/core/services/maintenance_reminder_tap_service.dart';
import 'package:petvita/core/services/navigation_service.dart';
import 'package:petvita/presentation/navigation/app_route_arguments.dart';
import 'package:petvita/presentation/navigation/main_navigation_controller.dart';

class DefaultMaintenanceReminderNavigation
    implements MaintenanceReminderNavigation {
  const DefaultMaintenanceReminderNavigation(this._mainNavigation);

  final MainNavigationController _mainNavigation;

  BuildContext? get _context => NavigationService.navigatorKey.currentContext;

  @override
  bool get isReady => _context?.mounted ?? false;

  @override
  void openVehicleMaintenancePlan(int vehicleId) {
    final context = _context;
    if (context == null || !context.mounted) return;
    Navigator.pushNamed(
      context,
      AppRoutes.vehicleDetailsRoute,
      arguments: VehicleDetailsRouteArguments(
        vehicleId: vehicleId,
        initialTab: VehicleDetailsTab.maintenancePlan,
      ),
    );
  }

  @override
  void openUpcomingMaintenance() {
    final context = _context;
    if (context == null || !context.mounted) return;
    final navigator = NavigationService.navigatorKey.currentState;
    if (navigator == null) return;
    _mainNavigation.revealRootTab(navigator, 2);
  }
}
