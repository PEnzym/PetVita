import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class Pet extends Equatable {
  final int? id;
  final String name;
  final String? breed;
  final DateTime? birthDate;
  final double mileage;
  final DateTime mileageLastUpdated;
  final DateTime boughtDate;
  final Uint8List? image;
  final bool imageLoaded;
  final String? model;
  final String? plateNumber;
  final String? vin;
  final String? engineNumber;

  const Pet({
    this.id,
    required this.name,
    this.breed,
    this.birthDate,
    required this.mileage,
    required this.mileageLastUpdated,
    required this.boughtDate,
    this.image,
    this.imageLoaded = true,
    this.model,
    this.plateNumber,
    this.vin,
    this.engineNumber,
  });

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] as int?,
      name: map['name'] as String,
      breed: map['breed'] as String?,
      birthDate: switch (map['birth_date']) {
        final String value => DateTime.tryParse(value),
        _ => null,
      },
      mileage: (map['mileage'] as num).toDouble(),
      mileageLastUpdated: DateTime.parse(map['mileage_last_updated'] as String),
      boughtDate: DateTime.parse(map['bought_date'] as String),
      image: map['image'] as Uint8List?,
      imageLoaded: map.containsKey('image'),
      model: map['model'] as String?,
      plateNumber: map['plate_number'] as String?,
      vin: map['vin'] as String?,
      engineNumber: map['engine_number'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'birth_date': birthDate?.toIso8601String(),
      'mileage': mileage,
      'mileage_last_updated': mileageLastUpdated.toIso8601String(),
      'bought_date': boughtDate.toIso8601String(),
      'image': image,
      'model': model,
      'plate_number': plateNumber,
      'vin': vin,
      'engine_number': engineNumber,
    };
  }

  Pet copyWith({
    int? id,
    String? name,
    String? breed,
    DateTime? birthDate,
    double? mileage,
    DateTime? mileageLastUpdated,
    DateTime? boughtDate,
    Uint8List? image,
    String? model,
    String? plateNumber,
    String? vin,
    String? engineNumber,
    bool clearImage = false, // Special flag to nullify image
    bool? imageLoaded,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      mileage: mileage ?? this.mileage,
      mileageLastUpdated: mileageLastUpdated ?? this.mileageLastUpdated,
      boughtDate: boughtDate ?? this.boughtDate,
      image: clearImage ? null : (image ?? this.image),
      imageLoaded: imageLoaded ?? this.imageLoaded,
      model: model ?? this.model,
      plateNumber: plateNumber ?? this.plateNumber,
      vin: vin ?? this.vin,
      engineNumber: engineNumber ?? this.engineNumber,
    );
  }

  bool isIdentical(Pet other) {
    return id == other.id &&
        name == other.name &&
        breed == other.breed &&
        birthDate == other.birthDate &&
        mileage == other.mileage &&
        mileageLastUpdated == other.mileageLastUpdated &&
        boughtDate == other.boughtDate &&
        image == other.image &&
        imageLoaded == other.imageLoaded &&
        model == other.model &&
        plateNumber == other.plateNumber &&
        vin == other.vin &&
        engineNumber == other.engineNumber;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    breed,
    birthDate,
    mileage,
    mileageLastUpdated,
    boughtDate,
    image,
    imageLoaded,
    model,
    plateNumber,
    vin,
    engineNumber,
  ];

  @override
  String toString() {
    return 'Pet{id: $id, name: $name}';
  }
}
