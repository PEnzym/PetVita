import 'dart:typed_data';

import 'package:petvita/application/ports/pet_repository_port.dart';
import 'package:petvita/data/models/pet.dart';
import 'package:petvita/data/sources/local/database_helper.dart';

class PetRepository implements PetRepositoryPort {
  final DatabaseHelper _dbHelper;

  PetRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  @override
  Future<List<Pet>> getVehicles() async {
    return await _dbHelper.getAllVehicles();
  }

  @override
  Future<Pet?> getVehicleById(int id) async {
    return await _dbHelper.getVehicleById(id);
  }

  @override
  Future<Uint8List?> getVehicleImage(int id) {
    return _dbHelper.getVehicleImage(id);
  }

  @override
  Future<void> addVehicle(Pet vehicle) async {
    await _dbHelper.insertVehicle(vehicle);
  }

  @override
  Future<void> updateVehicle(Pet vehicle) async {
    await _dbHelper.updateVehicle(vehicle);
  }

  @override
  Future<void> deleteVehicle(int id) async {
    await _dbHelper.deleteVehicle(id);
  }
}
