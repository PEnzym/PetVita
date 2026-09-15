import 'package:equatable/equatable.dart';

import 'package:petvita/core/failures/app_failure.dart';
import 'package:petvita/data/models/pet.dart';

abstract class PetState extends Equatable {
  const PetState();

  @override
  List<Object?> get props => [];
}

class PetInitial extends PetState {}

class PetLoading extends PetState {}

class PetLoaded extends PetState {
  final List<Pet> vehicles;
  final bool isRefreshing;
  final AppFailure? refreshFailure;

  const PetLoaded(
    this.vehicles, {
    this.isRefreshing = false,
    this.refreshFailure,
  });

  @override
  List<Object?> get props => [vehicles, isRefreshing, refreshFailure];
}

class PetError extends PetState {
  final AppFailure failure;

  const PetError(this.failure);

  @override
  List<Object> get props => [failure];
}
