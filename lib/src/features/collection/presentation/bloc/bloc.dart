import 'dart:developer';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/features/collection/domain/usecases/add_collection.dart';
import 'package:expensive_management/src/features/collection/domain/usecases/delete_collection.dart';
import 'package:expensive_management/src/features/collection/domain/usecases/update_collection.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/collection_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'event.dart';
part 'state.dart';

class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final AddCollectionUseCase addCollectionUseCase;
  final UpdateCollectionUseCase updateCollectionUseCase;
  final DeleteCollectionUseCase deleteCollectionUseCase;

  CollectionBloc({
    required this.addCollectionUseCase,
    required this.updateCollectionUseCase,
    required this.deleteCollectionUseCase,
  }) : super(CollectionInitialState()) {
    on<AddNewCollectionEvent>(_onAddCollectionEvent, transformer: droppable());
    on<UpdateCollectionEvent>(_onUpdateCollectionEvent, transformer: droppable());
    on<DeleteCollectionEvent>(_onDeleteCollectionEvent, transformer: droppable());
  }

  Future<void> _onAddCollectionEvent(AddNewCollectionEvent event, Emitter<CollectionState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(CollectionLoadingState());
    });
    final response = await addCollectionUseCase.call(event.data);
    if (response.isLeft) {
      final error = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(AddNewCollectionFailureState(message: error.message, key: error is ServerError ? error.key : null));
        return;
      });
    }
    final right = response.right;
    final collection = CollectionModel.fromJson(right);
    log("collection: $collection");
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(AddNewCollectionSuccessState());
    });
  }

  Future<void> _onUpdateCollectionEvent(UpdateCollectionEvent event, Emitter<CollectionState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(CollectionLoadingState());
    });
    final response = await updateCollectionUseCase.call(
      UpdateCollectionParams(collectionId: event.id, data: event.data),
    );
    if (response.isLeft) {
      final error = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(UpdateCollectionFailureState(message: error.message, key: error is ServerError ? error.key : null));
      });
    }

    final right = response.right;
    final collection = CollectionModel.fromJson(right);
    log("collection updated: $collection");
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(UpdateCollectionSuccessState());
    });
  }

  Future<void> _onDeleteCollectionEvent(DeleteCollectionEvent event, Emitter<CollectionState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(CollectionLoadingState());
    });
    final response = await deleteCollectionUseCase.call(event.id);
    if (response.isLeft) {
      final error = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(DeleteCollectionFailureState(message: error.message, key: error is ServerError ? error.key : null));
      });
    }

    final right = response.right;
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(right
          ? DeleteCollectionSuccessState()
          : DeleteCollectionFailureState(message: 'Có lỗi xảy ra. Vui lòng thử lại sau.'));
    });
  }
}
