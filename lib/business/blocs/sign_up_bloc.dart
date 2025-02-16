import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/data/provider/auth_provider.dart';
import 'package:expensive_management/presentation/screens/sign_up_screen/sign_up_event.dart';
import 'package:expensive_management/presentation/screens/sign_up_screen/sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {

  final _authProvider = AuthProvider();

  SignUpBloc() : super(InitialSignUp()) {
    on((event, emit) async {
      if (event is ValidateForm) {
        emit(InitialSignUp());
      }
      if (event is SignUpSubmitted) {
        emit(LoadingState());
        final connectivity = await Connectivity().checkConnectivity();
        if(connectivity == ConnectivityResult.none){
          emit(const SignUpFailed(errorMessage: 'No Networking'));
        }

        Map<String, dynamic> data = {
          "email": event.email,
          // "fullName": "string",
          "password": event.password,
          // "phone": "string",
          // "roles": [
          //   "string"
          // ],
          "username": event.username
        };
        final response = await _authProvider.signUp(data: data);
        if(response.isOK()){
          emit(SignUpSuccess());

        }else{
          emit(SignUpFailed(errorMessage: response.errors!.first.errorMessage.toString()));
        }
      }

    });
  }
}
