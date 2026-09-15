import 'package:equatable/equatable.dart';

class WeightEntry extends Equatable {
  final int? id;
  final int petId;
  final DateTime measuredAt;
  final double weight;
  final String unit;
  final String? notes;

  const WeightEntry({
    this.id,
    required this.petId,
    required this.measuredAt,
    required this.weight,
    required this.unit,
    this.notes,
  }) : assert(weight > 0);

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      id: map['id'] as int?,
      petId: map['pet_id'] as int,
      measuredAt: DateTime.parse(map['measured_at'] as String),
      weight: (map['weight'] as num).toDouble(),
      unit: map['unit'] as String,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'measured_at': measuredAt.toIso8601String(),
      'weight': weight,
      'unit': unit,
      'notes': notes,
    };
  }

  WeightEntry copyWith({
    int? id,
    int? petId,
    DateTime? measuredAt,
    double? weight,
    String? unit,
    String? notes,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      measuredAt: measuredAt ?? this.measuredAt,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, petId, measuredAt, weight, unit, notes];
}
