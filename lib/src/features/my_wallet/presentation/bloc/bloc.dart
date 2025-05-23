import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/features/planning_expenditure_analysis/analytics.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/my_wallet/domain/usecases/create_wallet.dart';
import 'package:expensive_management/src/features/my_wallet/domain/usecases/delete_wallet.dart';
import 'package:expensive_management/src/features/my_wallet/domain/usecases/get_wallets.dart';
import 'package:expensive_management/src/features/my_wallet/domain/usecases/update_wallet.dart';

part 'state.dart';
part 'event.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletsUseCase getWalletsUseCase;
  final CreateWalletUseCase createWalletUseCase;
  final UpdateWalletUseCase updateWalletUseCase;
  final DeleteWalletUseCase deleteWalletUseCase;

  WalletBloc({
    required this.getWalletsUseCase,
    required this.createWalletUseCase,
    required this.updateWalletUseCase,
    required this.deleteWalletUseCase,
  }) : super(WalletInitialState()) {
    on<GetWalletsEvent>(_onGetWalletsEvent, transformer: droppable());
    on<CreateWalletEvent>(_onCreateWalletEvent, transformer: droppable());
    on<DeleteWalletEvent>(_onDeleteWalletEvent, transformer: droppable());
    on<UpdateWalletEvent>(_onUpdateWalletEvent, transformer: droppable());
  }

  Future<void> _onGetWalletsEvent(GetWalletsEvent event, Emitter<WalletState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(WalletLoadingState());
    });

    final response = await getWalletsUseCase.call(NoParam());
    if (response.isLeft) {
      final error = response.left;
      if (error is ServerError && error.key == 'token_expired') {
        //logout()
      }

      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(GetListWalletErrorState(message: error.message, key: error is ServerError ? error.key : ''));
      });
      return;
    }

    final data = response.right;
    double amount = 0.0;
    final moneyTotal = data['moneyTotal'];
    if (moneyTotal != null) {
      if (moneyTotal is int || moneyTotal is num) {
        amount = moneyTotal.toDouble();
      } else if (moneyTotal is double) {
        amount = moneyTotal;
      } else if (moneyTotal is String) {
        amount = double.tryParse(moneyTotal) ?? 0.0;
      }
    }
    List<Wallet> wallets = [];
    final walletData = data['walletList'];
    if (walletData != null && walletData is List) {
      wallets = walletData.map((e) => Wallet.fromJson(e)).toList();
    }

    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(GetListWalletSuccessState(
        moneyTotal: amount,
        wallets: wallets,
      ));
    });
  }

  Future<void> _onCreateWalletEvent(CreateWalletEvent event, Emitter<WalletState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(WalletLoadingState());
    });

    final response = await createWalletUseCase.call(event.data);
    if (response.isLeft) {
      final error = response.left;
      if (error is ServerError && error.key == 'token_expired') {
        //logout()
      }

      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(CreateWalletErrorState(message: error.message, key: error is ServerError ? error.key : ''));
      });
      return;
    }

    final data = response.right;

    final wallet = Wallet.fromJson(data);

    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(CreateWalletSuccessState(wallet: wallet));
    });
  }

  Future<void> _onDeleteWalletEvent(DeleteWalletEvent event, Emitter<WalletState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(WalletLoadingState());
    });

    final response = await deleteWalletUseCase.call(event.walletId);
    if (response.isLeft) {
      final error = response.left;
      if (error is ServerError && error.key == 'token_expired') {
        //logout()
      }

      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(CreateWalletErrorState(message: error.message, key: error is ServerError ? error.key : ''));
      });
      return;
    }

    final data = response.right;

    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(data ? DeleteWalletSuccessState() : DeleteWalletErrorState(message: 'Failed to delete wallet'));
    });
  }

  Future<void> _onUpdateWalletEvent(UpdateWalletEvent event, Emitter<WalletState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(WalletLoadingState());
    });

    final response = await updateWalletUseCase.call(
      UpdateWalletUseCaseParams(walletId: event.walletId, data: event.data),
    );
    if (response.isLeft) {
      final error = response.left;
      if (error is ServerError && error.key == 'token_expired') {
        //logout()
      }

      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(UpdateWalletErrorState(message: error.message, key: error is ServerError ? error.key : ''));
      });
      return;
    }

    // final data = response.right;
    // final wallet = Wallet.fromJson(data);

    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(UpdateWalletSuccessState());
    });
  }
}
