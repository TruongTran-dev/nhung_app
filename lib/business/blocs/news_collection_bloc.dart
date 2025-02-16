import 'package:expensive_management/data/models/collection_model.dart';
import 'package:expensive_management/data/provider/collection_provider.dart';
import 'package:expensive_management/data/provider/wallet_provider.dart';
import 'package:expensive_management/data/response/base_get_response.dart';
import 'package:expensive_management/data/response/get_list_wallet_response.dart';
import 'package:expensive_management/presentation/screens/planning_screen/balance_payments/balance_payment.dart';
import 'package:expensive_management/presentation/screens/planning_screen/expenditure_analysis/analytics.dart';
import '../../presentation/screens/collection_screen/collection_event.dart';
import '../../presentation/screens/collection_screen/collection_state.dart';

class NewsCollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final BuildContext context;

  final _walletProvider = WalletProvider();
  final _collectionProvider = CollectionProvider();

  NewsCollectionBloc(this.context) : super(LoadingState()) {
    on((event, emit) async {
      if (event is CollectionInitialized) {
        emit(LoadingState());

        final response = await _walletProvider.getListWallet();

        if (response is GetListWalletResponse) {
          emit(FetchDataSuccessState(listWallet: response.walletList));
        } else {
          emit(const FailureState(errorMessage: 'Internal Server Error'));
        }
      }
      if (event is AddNewCollection) {
        emit(LoadingState());
        final Map<String, dynamic> data = {
          "amount": event.amount,
          'ariseDate': event.ariseDate,
          "categoryId": event.categoryId,
          "description": event.description,
          "transactionType": event.transactionType,
          "walletId": event.walletId,
          if (isNotNullOrEmpty(event.imageUrl)) "imageUrl": event.imageUrl,
        };

        final response = await _collectionProvider.newCollection(data: data);

        if (response is CollectionModel) {
          emit(AddSuccessState());
        } else if (response is ExpiredTokenGetResponse && context.mounted) {
          logoutIfNeed(context);
        } else {
          emit(const FailureState(errorMessage: 'Thêm mới giao dịch không thành công!'));
        }
      }

      if (event is UpdateCollection) {
        emit(LoadingState());

        final Map<String, dynamic> data = {
          "amount": event.amount,
          'ariseDate': event.ariseDate,
          "categoryId": event.categoryId,
          "description": event.description,
          "transactionType": event.transactionType,
          "walletId": event.walletId,
          "imageUrl": event.imageUrl,
        };

        final response = await _collectionProvider.updateCollection(collectionId: event.collectionId, data: data);

        if (response is CollectionModel) {
          emit(UpdateSuccessState());
        } else {
          emit(const FailureState(errorMessage: 'Cập nhật giao dịch thất bại!'));
        }
      }

      if (event is DeleteCollection) {
        await _collectionProvider.deleteCollection(collectionId: event.collectionId);
      }
    });
  }
}
