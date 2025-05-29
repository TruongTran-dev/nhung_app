import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/features/recurring_transaction/domain/usecases/add_recurring.dart';
import 'package:expensive_management/src/features/recurring_transaction/domain/usecases/delete_recurring.dart';
import 'package:expensive_management/src/features/recurring_transaction/domain/usecases/update_recurring.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'recurring_info_event.dart';
part 'recurring_info_state.dart';

class RecurringInfoBloc extends Bloc<RecurringInfoEvent, RecurringInfoState> {
  final AddRecurringUseCase addRecurringUseCase;
  final UpdateRecurringUseCase updateRecurringUseCase;
  final DeleteRecurringUseCase deleteRecurringUseCase;

  RecurringInfoBloc({
    required this.addRecurringUseCase,
    required this.updateRecurringUseCase,
    required this.deleteRecurringUseCase,
  }) : super(RecurringInfoInitial()) {
    on<AddRecurringEvent>(_onAddRecurringEvent, transformer: droppable());
    on<UpdateRecurringEvent>(_onUpdateRecurringEvent, transformer: droppable());
    on<DeleteRecurringEvent>(_onDeleteRecurringEvent, transformer: droppable());
  }

  Future<void> _onAddRecurringEvent(AddRecurringEvent event, Emitter<RecurringInfoState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(RecurringInfoLoading());
    });
    final result = await addRecurringUseCase(event.data);

    if (result.isLeft) {
      final left = result.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(AddRecurringFailureState(
          message: left.message,
          key: left is ServerError ? left.key : null,
        ));
      });
      return;
    }

    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(AddRecurringSuccessState());
    });
  }

  Future<void> _onUpdateRecurringEvent(UpdateRecurringEvent event, Emitter<RecurringInfoState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(RecurringInfoLoading());
    });
    final result = await updateRecurringUseCase(UpdateRecurringParams(id: event.id, data: event.data));

    if (result.isLeft) {
      final left = result.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(UpdateRecurringFailureState(
          message: left.message,
          key: left is ServerError ? left.key : null,
        ));
      });
      return;
    }

    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(UpdateRecurringSuccessState());
    });
  }

  Future<void> _onDeleteRecurringEvent(DeleteRecurringEvent event, Emitter<RecurringInfoState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(RecurringInfoLoading());
    });
    final result = await deleteRecurringUseCase(event.id);

    if (result.isLeft) {
      final left = result.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(DeleteRecurringFailureState(
          message: left.message,
          key: left is ServerError ? left.key : null,
        ));
      });
      return;
    }

    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(DeleteRecurringSuccessState());
    });
  }
}
