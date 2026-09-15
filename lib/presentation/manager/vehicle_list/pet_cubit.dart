import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:petvita/application/use_cases/pet_use_cases.dart';
import 'package:petvita/core/failures/app_failure.dart';
import 'package:petvita/core/utils/operation_result.dart';
import 'package:petvita/data/models/pet.dart';
import 'pet_state.dart';

class PetCubit extends Cubit<PetState> {
  final PetUseCases _useCases;
  int _loadRevision = 0;

  PetCubit(this._useCases) : super(PetInitial());

  Future<OperationResult> fetchVehicles() async {
    if (isClosed) {
      return OperationFailure.capture(
        AppFailureKind.load,
        StateError('PetCubit is closed'),
        StackTrace.current,
        context: 'PetCubit.fetchVehicles.closed',
      );
    }
    final revision = ++_loadRevision;
    final previousVehicles = state is PetLoaded
        ? (state as PetLoaded).vehicles
        : null;
    if (previousVehicles == null) {
      emit(PetLoading());
    } else {
      emit(PetLoaded(previousVehicles, isRefreshing: true));
    }
    try {
      final vehicles = await _useCases.getVehicles();
      if (isClosed || revision != _loadRevision) {
        return OperationSuccess();
      }
      emit(PetLoaded(vehicles));
      return OperationSuccess();
    } catch (error, stackTrace) {
      final failure = OperationFailure.capture(
        previousVehicles == null ? AppFailureKind.load : AppFailureKind.refresh,
        error,
        stackTrace,
        context: 'PetCubit.fetchVehicles',
      );
      if (!isClosed && revision == _loadRevision) {
        if (previousVehicles == null) {
          emit(PetError(failure.failure));
        } else {
          emit(
            PetLoaded(previousVehicles, refreshFailure: failure.failure),
          );
        }
      }
      return failure;
    }
  }

  Future<OperationResult> addVehicle(Pet vehicle) async {
    try {
      await _useCases.addVehicle(vehicle);
    } catch (error, stackTrace) {
      return OperationFailure.capture(
        AppFailureKind.save,
        error,
        stackTrace,
        context: 'PetCubit.addVehicle',
      );
    }
    return _successAfterRefresh();
  }

  Future<OperationResult> updateVehicle(Pet vehicle) async {
    try {
      await _useCases.updateVehicle(vehicle);
    } catch (error, stackTrace) {
      return OperationFailure.capture(
        AppFailureKind.save,
        error,
        stackTrace,
        context: 'PetCubit.updateVehicle',
      );
    }
    return _successAfterRefresh();
  }

  Future<OperationResult> deleteVehicle(int id) async {
    try {
      await _useCases.deleteVehicle(id);
    } catch (error, stackTrace) {
      return OperationFailure.capture(
        AppFailureKind.delete,
        error,
        stackTrace,
        context: 'PetCubit.deleteVehicle',
      );
    }
    return _successAfterRefresh();
  }

  Future<OperationResult> _successAfterRefresh() async {
    final refreshResult = await fetchVehicles();
    return OperationSuccess(
      followUpFailure: refreshResult is OperationFailure ? refreshResult : null,
    );
  }
}
