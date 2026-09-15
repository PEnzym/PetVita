import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:petvita/core/constants/app_routes.dart';
import 'package:petvita/data/models/predicted_maintenance.dart';
import 'package:petvita/data/models/pet.dart';
import 'package:petvita/i18n/generated/app_localizations.dart';
import 'package:petvita/presentation/formatters/bidi_text_direction.dart';
import 'package:petvita/presentation/manager/upcoming_maintenance/upcoming_maintenance_cubit.dart';
import 'package:petvita/presentation/manager/upcoming_maintenance/upcoming_maintenance_state.dart';
import 'package:petvita/presentation/navigation/app_route_arguments.dart';
import 'package:petvita/presentation/screens/vehicle/widgets/info_grid_item.dart';
import 'package:petvita/presentation/screens/vehicle/widgets/maintenance_list_item_card.dart';

class OverviewTab extends StatelessWidget {
  final Pet vehicle;

  const OverviewTab({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpcomingMaintenanceCubit, UpcomingMaintenanceState>(
      builder: (context, upcomingState) {
        List<PredictedMaintenanceInfo> allPredictions = [];
        if (upcomingState is UpcomingMaintenanceLoaded) {
          allPredictions = upcomingState.allPredictions;
        }
        final nextServiceForThisVehicle = allPredictions
            .where((p) => p.vehicle.id == vehicle.id)
            .sorted((a, b) => a.predictedDueDate.compareTo(b.predictedDueDate))
            .firstOrNull;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.petName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.addVehicleRoute,
                        arguments: AddEditPetRouteArguments(
                          pet: vehicle,
                        ),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.edit,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 15.0;
                  final itemWidth = (constraints.maxWidth - spacing) / 2;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _directionalInfoItem(
                          context,
                          label: AppLocalizations.of(context)!.petBreed,
                          value: vehicle.breed,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _directionalInfoItem(
                          context,
                          label: AppLocalizations.of(context)!.petBirthDate,
                          value: vehicle.birthDate == null
                              ? null
                              : MaterialLocalizations.of(context)
                                    .formatMediumDate(vehicle.birthDate!),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 25),
              Text(
                AppLocalizations.of(context)!.nextMaintenance,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              nextServiceForThisVehicle != null
                  ? MaintenanceListItemCard.planItem(
                      context,
                      nextServiceForThisVehicle,
                    )
                  : Text(
                      AppLocalizations.of(context)!.noNextMaintenance,
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _directionalInfoItem(
    BuildContext context, {
    required String label,
    required String? value,
  }) {
    final displayValue = value ?? "--";
    return InfoGridItem(
      label: label,
      value: displayValue,
      valueTextDirection: BidiTextDirection.resolve(
        displayValue,
        fallback: Directionality.of(context),
      ),
    );
  }
}
