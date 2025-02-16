import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/data/provider/auth_provider.dart';
import 'package:expensive_management/presentation/screens/login_screen/login_event.dart';
import 'package:expensive_management/presentation/screens/login_screen/login_state.dart';
import 'package:expensive_management/presentation/screens/planning_screen/balance_payments/balance_payment.dart';

class LoginBloc extends Bloc<SignInEvent, LoginState> {
  final _authProvider = AuthProvider();

  LoginBloc() : super(InitialLogin()) {
    on((event, emit) async {
      if (event is ValidateForm) {
        emit(InitialLogin());
      }
      if (event is LoginSubmitted) {
        emit(LoadingState());
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          emit(const LoginFailed(errorMessage: 'No Networking'));
        } else {
          final response = await _authProvider.signIn(username: event.username, password: event.password);

          if (response.isOK()) {
            await SharedPreferencesStorage().setLoggedOutStatus(false);

            ///save user info
            await SharedPreferencesStorage().setSaveUserInfo(response.data);

            emit(LoginSuccess());
          } else {
            emit(LoginFailed(errorMessage: response.errors!.first.errorMessage.toString()));
          }
        }
      }
    });
  }
}
