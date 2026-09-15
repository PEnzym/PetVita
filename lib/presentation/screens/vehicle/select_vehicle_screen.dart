import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:petvita/application/use_cases/maintenance_plan_use_cases.dart';
import 'package:petvita/application/use_cases/service_log_use_cases.dart';
import 'package:petvita/core/constants/app_colors.dart';
import 'package:petvita/core/theme/app_theme.dart';
import 'package:petvita/core/widgets/gradient_background.dart';
import 'package:petvita/data/models/pet.dart';
import 'package:petvita/i18n/generated/app_localizations.dart';
import 'package:petvita/presentation/manager/maintenance_plan/maintenance_plan_cubit.dart';
import 'package:petvita/presentation/manager/service_log/service_log_cubit.dart';
import 'package:petvita/presentation/images/pet_thumbnail.dart';
import 'package:petvita/presentation/screens/maintenance/log_maintenance_screen.dart';

class SelectVehicleScreen extends StatelessWidget {
  final List<Pet> vehicles;

  const SelectVehicleScreen({super.key, required this.vehicles});

  void _navigateToLogMaintenance(
    BuildContext context,
    int vehicleId,
    String vehicleName,
  ) {
    final maintenancePlanUseCases = context.read<MaintenancePlanUseCases>();
    final serviceLogUseCases = context.read<ServiceLogUseCases>();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (newRouteContext) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  MaintenancePlanCubit(maintenancePlanUseCases, vehicleId)
                    ..fetchPlanItems(),
            ),
            BlocProvider(
              create: (_) =>
                  ServiceLogCubit(serviceLogUseCases, vehicleId)
                    ..fetchServiceLogs(),
            ),
          ],
          child: LogMaintenanceScreen(
            vehicleId: vehicleId,
            vehicleName: vehicleName,
            logToEdit: null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeExtensions = Theme.of(context).extension<AppThemeExtensions>()!;
    return GradientBackground(
      gradient: themeExtensions.primaryGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.chooseVehicle),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.inverseSurface.withValues(alpha: 0.1),
          elevation: 0,
          systemOverlayStyle: AppTheme.gradientSystemOverlayStyle,
        ),
        body: SafeArea(
          top: false,
          child: ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Card(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: PetThumbnail(
                    pet: vehicle,
                    width: 50,
                    height: 50,
                  ),
                  title: Text(
                    vehicle.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    vehicle.breed ?? AppLocalizations.of(context)!.petBreed,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  onTap: () {
                    if (vehicle.id != null) {
                      _navigateToLogMaintenance(
                        context,
                        vehicle.id!,
                        vehicle.name,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.loadErrorMessage,
                          ),
                          backgroundColor: AppColors.urgentReminderText,
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
