import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/shared/data/models/limit_expenditure_model.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/features/limit_expenditure/domain/usecases/add_limit.dart';
import 'package:expensive_management/src/features/limit_expenditure/domain/usecases/delete_limit.dart';
import 'package:expensive_management/src/features/limit_expenditure/domain/usecases/get_limits.dart';
import 'package:expensive_management/src/features/limit_expenditure/domain/usecases/update_limit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'state.dart';
part 'event.dart';

class LimitExpenditureBloc extends Bloc<LimitExpenditureEvent, LimitExpenditureState> {
  final GetLimitsUseCase getLimitsUseCase;
  final AddLimitUseCase addLimitUseCase;
  final UpdateLimitUseCase updateLimitUseCase;
  final DeleteLimitUseCase deleteLimitUseCase;

  LimitExpenditureBloc({
    required this.getLimitsUseCase,
    required this.addLimitUseCase,
    required this.updateLimitUseCase,
    required this.deleteLimitUseCase,
  }) : super(LimitExpenditureInitialState()) {
    on<GetLimitsEvent>(_onGetLimits, transformer: droppable());
    on<AddLimitEvent>(_onAddLimit, transformer: droppable());
    on<UpdateLimitEvent>(_onUpdateLimit, transformer: droppable());
    on<DeleteLimitEvent>(_onDeleteLimit, transformer: droppable());
  }

  Future<void> _onGetLimits(GetLimitsEvent event, Emitter<LimitExpenditureState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(LimitExpenditureLoadingState());
    });
    final response = await getLimitsUseCase.call(event.data);
    if (response.isLeft) {
      final left = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(GetLimitsErrorState(left.message, key: left is ServerError ? left.key : null));
      });
      return;
    }

    final right = response.right;
    final content = right['content'];
    if (content != null && content is List) {
      final limits = content.map((e) => LimitModel.fromJson(e)).toList();
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(GetLimitsSuccessState(limits));
      });
    } else {
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(GetLimitsErrorState('Invalid response format'));
      });
    }
  }

  Future<void> _onAddLimit(AddLimitEvent event, Emitter<LimitExpenditureState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(LimitExpenditureLoadingState());
    });
    final response = await addLimitUseCase.call(event.data);
    if (response.isLeft) {
      final left = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(AddLimitErrorState(left.message, key: left is ServerError ? left.key : null));
      });
      return;
    }
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(AddLimitSuccessState());
    });
  }

  Future<void> _onUpdateLimit(UpdateLimitEvent event, Emitter<LimitExpenditureState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(LimitExpenditureLoadingState());
    });
    final response = await updateLimitUseCase.call(UpdateLimitParams(limitId: event.id, data: event.data));
    if (response.isLeft) {
      final left = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(UpdateLimitErrorState(left.message, key: left is ServerError ? left.key : null));
      });
      return;
    }
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(UpdateLimitSuccessState());
    });
  }

  Future<void> _onDeleteLimit(DeleteLimitEvent event, Emitter<LimitExpenditureState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(LimitExpenditureLoadingState());
    });
    final response = await deleteLimitUseCase.call(event.id);
    if (response.isLeft) {
      final left = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(DeleteLimitErrorState(left.message, key: left is ServerError ? left.key : null));
      });
      return;
    }
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(DeleteLimitSuccessState());
    });
  }
}
