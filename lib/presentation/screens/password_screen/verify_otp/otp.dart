import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:expensive_management/app/app_routes.dart';
import 'package:expensive_management/data/provider/auth_provider.dart';
import 'package:expensive_management/presentation/widgets/primary_button.dart';
import 'package:expensive_management/utils/screen_utilities.dart';

class OtpPage extends StatefulWidget {
  final String email;

  const OtpPage({Key? key, required this.email}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String otpCode = '';
  int _timerCounter = 59;

  bool isEnableButton = false;

  late Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpBloc, OtpState>(
      listener: (context, state) {
        if (state is LoadingState) {
          showLoading(context);
        }
        if (state is ValidateState) {
          setState(() {
            isEnableButton = state.isEnableButton;
          });
        }
        if (state is SuccessState) {
          Navigator.pushNamed(context, AppRoutes.newPassword, arguments: widget.email);
        }
        if (state is FailureState) {
          showMessage1OptionDialog(context, state.errorMessage);
        }
      },
      child: _body(),
    );
  }

  Widget _body() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.white),
        ),
        title: const Text('Nhập mã OTP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Text(
                        'Chúng tôi sẽ gửi một mã OTP đển địa chỉ email mà bạn vừa nhập, vui lòng kiểm tra email của bạn!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 50),
                      child: Text(
                        'email: ${widget.email}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black),
                      ),
                    ),
                    OtpTextField(
                      numberOfFields: 6,
                      textStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 26),
                      keyboardType: TextInputType.number,
                      borderWidth: 2,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      borderColor: Theme.of(context).primaryColor,
                      enabledBorderColor: Colors.grey,
                      disabledBorderColor: Colors.blue,
                      focusedBorderColor: Theme.of(context).primaryColor,
                      showFieldAsBox: true,
                      onCodeChanged: (String code) {},
                      onSubmit: (String verificationCode) {
                        setState(() {
                          otpCode = verificationCode;
                          // BlocProvider.of<OtpBloc>(context).add(SubmitOtp(otpCode: otpCode, email: widget.email));
                          BlocProvider.of<OtpBloc>(context).add(const ValidatedOtp(isValidate: true));
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            _buttonVerify(context),
          ],
        ),
      ),
    );
  }

  Widget _buttonVerify(BuildContext context) {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_timerCounter > 0) {
          setState(() {
            _timerCounter--;
          });
        } else {
          _timer.cancel();
        }
      },
    );
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(0.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Không nhận được mã OTP?', style: TextStyle(fontSize: 14, color: Colors.black)),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: InkWell(
                    onTap: () {
                      BlocProvider.of<OtpBloc>(context).add(ResendOtp(email: widget.email));
                      setState(() {
                        otpCode = '';
                      });
                    },
                    child: Text(
                      (_timerCounter == 0) ? 'Gửi lại OTP' : '00:$_timerCounter',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              height: 50,
              child: PrimaryButton(
                text: 'Xác nhận',
                isDisable: !isEnableButton,
                onTap: isEnableButton
                    ? () async {
                        BlocProvider.of<OtpBloc>(context).add(SubmitOtp(otpCode: otpCode, email: widget.email));
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final _authProvider = AuthProvider();

  OtpBloc() : super(LoadingState()) {
    on((event, emit) async {
      if (event is InitializedOtp) {
        emit(const ValidateState(isEnableButton: false));
      }
      if (event is ValidatedOtp) {
        emit(const ValidateState(isEnableButton: true));
      }
      if (event is ResendOtp) {
        emit(LoadingState());

        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          emit(const FailureState(errorMessage: 'No Internet Connection'));
        }
        final response = await _authProvider.forgotPassword(email: event.email);

        if (response.isOK()) {
          emit(const ValidateState(isEnableButton: false));
        } else {
          emit(FailureState(errorMessage: response.errors?.first.errorMessage ?? 'Có lỗi xảy ra. Vui lòng thử lại!'));
        }
      }
      if (event is SubmitOtp) {
        emit(LoadingState());

        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          emit(const FailureState(errorMessage: 'No Internet Connection'));
        }
        final response = await _authProvider.verifyOtp(email: event.email, otpCode: event.otpCode);

        if (response.isOK()) {
          emit(SuccessState());
        } else {
          emit(FailureState(errorMessage: response.errors?.first.errorMessage ?? 'Có lỗi xảy ra. Vui lòng thử lại!'));
        }
      }
    });
  }
}

abstract class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object> get props => [];
}

class InitializedOtp extends OtpEvent {}

class ValidatedOtp extends OtpEvent {
  final bool isValidate;

  const ValidatedOtp({this.isValidate = false});

  @override
  List<Object> get props => [isValidate];
}

class ResendOtp extends OtpEvent {
  final String email;

  const ResendOtp({required this.email});

  @override
  List<Object> get props => [email];
}

class SubmitOtp extends OtpEvent {
  final String otpCode;
  final String email;

  const SubmitOtp({required this.otpCode, required this.email});

  @override
  List<Object> get props => [otpCode, email];
}

abstract class OtpState extends Equatable {
  const OtpState();

  @override
  List<Object> get props => [];
}

class ValidateState extends OtpState {
  final bool isEnableButton;

  const ValidateState({this.isEnableButton = false});
}

class LoadingState extends OtpState {}

class SuccessState extends OtpState {}

class FailureState extends OtpState {
  final String errorMessage;

  const FailureState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
