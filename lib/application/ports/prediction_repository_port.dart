import 'package:petvita/application/queries/maintenance_data_snapshot.dart';

abstract interface class PredictionRepositoryPort {
  Future<MaintenanceDataSnapshot> getPredictionSnapshot();
}
