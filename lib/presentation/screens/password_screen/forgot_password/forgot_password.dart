import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/app/app_routes.dart';
import 'package:expensive_management/data/provider/auth_provider.dart';
import 'package:expensive_management/presentation/widgets/input_field.dart';
import 'package:expensive_management/presentation/widgets/primary_button.dart';
import 'package:expensive_management/utils/app_constants.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/utils.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      listener: (context, state) {
        if (state is LoadingState) {
          showLoading(context);
        }
        if (state is SuccessState) {
          Navigator.pushNamed(context, AppRoutes.otp, arguments: _emailController.text.trim());
        }
        if (state is FailureState) {
          showMessage1OptionDialog(context, state.errorMessage);
        }
      },
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.white),
          ),
          title: const Text('Quên mật khẩu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppConstants.forgotPassword,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Theme.of(context).primaryColor, height: 1.4),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 80, right: 16),
                        child: Form(
                          key: _formKey,
                          child: SizedBox(
                            height: 50,
                            child: Input(
                              textInputAction: TextInputAction.done,
                              controller: _emailController,
                              prefixIcon: Icons.mail_outline,
                              hint: 'Nhập địa chỉ email',
                              validator: (v) {
                                if (v == null || isNullOrEmpty(v)) {
                                  return 'Địa chỉ email là bắt buộc';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buttonSendCode()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttonSendCode() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: PrimaryButton(
        text: 'Gửi mã OTP',
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            BlocProvider.of<ForgotPasswordBloc>(context).add(SubmitEmail(email: _emailController.text.trim()));
          }
        },
      ),
    );
  }
}

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final _authProvider = AuthProvider();

  ForgotPasswordBloc() : super(LoadingState()) {
    on((event, emit) async {
      if (event is Initialized) {
        emit(ValidateState());
      }
      if (event is SubmitEmail) {
        emit(LoadingState());

        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          emit(const FailureState(errorMessage: 'No Internet Connection'));
        }
        final response = await _authProvider.forgotPassword(email: event.email);

        if (response.isOK()) {
          emit(SuccessState());
        } else {
          emit(FailureState(errorMessage: response.errors?.first.errorMessage ?? 'Có lỗi xảy ra. Vui lòng thử lại!'));
        }
      }
    });
  }
}

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object> get props => [];
}

class Initialized extends ForgotPasswordEvent {}

class SubmitEmail extends ForgotPasswordEvent {
  final String email;

  const SubmitEmail({required this.email});

  @override
  List<Object> get props => [email];
}

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object> get props => [];
}

class ValidateState extends ForgotPasswordState {}

class LoadingState extends ForgotPasswordState {}

class SuccessState extends ForgotPasswordState {}

class FailureState extends ForgotPasswordState {
  final String errorMessage;

  const FailureState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
