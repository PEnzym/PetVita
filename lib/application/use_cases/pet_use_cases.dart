import 'dart:typed_data';

import 'package:petvita/application/ports/preferences_ports.dart';
import 'package:petvita/application/ports/pet_repository_port.dart';
import 'package:petvita/data/models/pet.dart';

final class PetUseCases {
  const PetUseCases(this._repository, this._preferences);

  final PetRepositoryPort _repository;
  final DefaultVehiclePreferences _preferences;

  Future<List<Pet>> getVehicles() => _repository.getVehicles();

  Future<Pet?> getVehicleById(int id) => _repository.getVehicleById(id);

  Future<Uint8List?> getVehicleImage(int id) => _repository.getVehicleImage(id);

  Future<void> addVehicle(Pet vehicle) {
    return _repository.addVehicle(vehicle);
  }

  Future<void> updateVehicle(Pet vehicle) {
    return _repository.updateVehicle(vehicle);
  }

  Future<void> deleteVehicle(int id) async {
    await _repository.deleteVehicle(id);
    final defaultVehicleId = await _preferences.getDefaultVehicleId();
    if (defaultVehicleId == id) {
      await _preferences.setDefaultVehicleId(null);
    }
  }
}
