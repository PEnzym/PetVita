import 'package:petvita/data/models/maintenance_plan_item.dart';
import 'package:petvita/data/models/service_log_entry.dart';
import 'package:petvita/data/models/pet.dart';
import 'package:petvita/presentation/manager/maintenance_plan/maintenance_plan_cubit.dart';
import 'package:petvita/presentation/manager/service_log/service_log_cubit.dart';

class AddEditPetRouteArguments {
  final Pet? pet;

  const AddEditPetRouteArguments({this.pet});
}

enum VehicleDetailsTab { overview, maintenancePlan, serviceHistory }

class VehicleDetailsRouteArguments {
  final int? vehicleId;
  final VehicleDetailsTab initialTab;

  const VehicleDetailsRouteArguments({
    required this.vehicleId,
    this.initialTab = VehicleDetailsTab.overview,
  });
}

class AddEditMaintenancePlanItemRouteArguments {
  final int vehicleId;
  final String vehicleName;
  final MaintenancePlanItem? planItem;
  final MaintenancePlanCubit maintenancePlanCubit;
  final ServiceLogCubit serviceLogCubit;

  const AddEditMaintenancePlanItemRouteArguments({
    required this.vehicleId,
    required this.vehicleName,
    this.planItem,
    required this.maintenancePlanCubit,
    required this.serviceLogCubit,
  });
}

class LogMaintenanceRouteArguments {
  final int vehicleId;
  final String vehicleName;
  final ServiceLogWithItems? logToEdit;
  final ServiceLogCubit serviceLogCubit;
  final MaintenancePlanCubit maintenancePlanCubit;

  const LogMaintenanceRouteArguments({
    required this.vehicleId,
    required this.vehicleName,
    this.logToEdit,
    required this.serviceLogCubit,
    required this.maintenancePlanCubit,
  });
}
