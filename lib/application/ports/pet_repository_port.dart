import 'dart:typed_data';

import 'package:petvita/data/models/pet.dart';

abstract interface class PetRepositoryPort {
  Future<List<Pet>> getVehicles();

  Future<Pet?> getVehicleById(int id);

  Future<Uint8List?> getVehicleImage(int id);

  Future<void> addVehicle(Pet vehicle);

  Future<void> updateVehicle(Pet vehicle);

  Future<void> deleteVehicle(int id);
}
