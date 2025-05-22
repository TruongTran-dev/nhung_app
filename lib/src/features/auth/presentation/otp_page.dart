import 'dart:async';
import 'dart:developer';

import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/auth/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:expensive_management/src/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/presentation/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';

class OtpPage extends StatefulWidget {
  final String? email;

  const OtpPage({super.key, this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String otpCode = '';
  late int _timerCounter;

  bool isEnableButton = false;

  late final AuthBloc _authBloc;
  PhoneValidationState _optValidationState = PhoneValidationState.none;
  late StreamController<int> _countdownController;
  late Stream<int> _countdownStream;

  @override
  void initState() {
    _authBloc = serviceLocator<AuthBloc>();
    _timerCounter = 59;
    // Initialize countdown controller and stream
    _countdownController = StreamController<int>();
    _countdownStream = _countdownController.stream.asBroadcastStream();

    // Start countdown timer if sendAfter is available
    if (_timerCounter > 0) {
      _startCountdown();
    }

    super.initState();
  }

  void _startCountdown() {
    try {
      // Parse the initial seconds from the string

      _countdownController.add(_timerCounter);

      if (_timerCounter > 0) {
        Timer.periodic(const Duration(seconds: 1), (timer) {
          _timerCounter--;

          if (_timerCounter <= 0) {
            timer.cancel();
            _timerCounter = 0;
          }

          if (!_countdownController.isClosed) {
            _countdownController.add(_timerCounter);
          }
        });
      }
    } catch (e) {
      _timerCounter = 0;
      _countdownController.add(0);
    }
  }

  @override
  void dispose() {
    _countdownController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      bloc: _authBloc,
      listener: (context, state) {
        switch (state.runtimeType) {
          case OTPVerifySuccessState:
            _optValidationState = PhoneValidationState.valid;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!context.mounted) return;
              context.push(AppRoutes.newPwd, extra: widget.email);
            });
            break;
          case OTPVerifyFailedState:
            final errorState = state as OTPVerifyFailedState;
            _optValidationState = PhoneValidationState.invalid;
            AppUtils.showSnackBar(context, errorState.errorMessage);
            break;

          case GetOTPSuccessState:
            _optValidationState = PhoneValidationState.none;
            _timerCounter = 59;
            _startCountdown();
            AppUtils.showSnackBar(context, "Gửi mã OTP thành công, vui lòng kiểm tra email của bạn");
            break;
          case GetOTPFailedState:
            final errorState = state as GetOTPFailedState;
            _optValidationState = PhoneValidationState.none;
            AppUtils.showSnackBar(context, errorState.errorMessage);
            break;
          default:
            break;
        }
      },
      builder: (context, state) {
        final isLoading = state is LoadingState;
        return Stack(
          children: [
            _body(),
            isLoading ? Positioned.fill(child: const LoadingWidget()) : const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget _body() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        leading: InkWell(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.white),
        ),
        title: const Text(
          'Nhập mã OTP',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
                    Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Text(
                        'Chúng tôi sẽ gửi một mã OTP đến địa chỉ email: (${widget.email}), vui lòng kiểm tra email của bạn!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 40),
                    OTPInput(
                      otpValidationState: _optValidationState,
                      onVerify: (otp) {
                        log("otp: $otp");
                        // Validate OTP length
                        if (otp.length == 6) {
                          otpCode = otp;
                          isEnableButton = true;
                        } else {
                          isEnableButton = false;
                        }
                        setState(() {});
                      },
                      onResetOTPState: () {
                        _optValidationState = PhoneValidationState.none;
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 36),
                    _buildResendOtpButton(),
                  ],
                ),
              ),
            ),
            _buttonVerify(),
          ],
        ),
      ),
    );
  }

  Widget _buildResendOtpButton() {
    // Start timer when widget builds

    return StreamBuilder(
      stream: _countdownStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final remainingTime = snapshot.data!;
        String timeRemaining = remainingTime == 0 ? "" : " ($remainingTime)";
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: remainingTime > 0 ? null : _resendOTP,
              style: TextButton.styleFrom(
                foregroundColor: context.theme.primaryColor,
                disabledForegroundColor: Colors.grey.withOpacity(0.5),
                padding: EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Text(
                "Gửi lại mã$timeRemaining",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: remainingTime == 0 ? context.theme.primaryColor : Colors.grey.withOpacity(0.5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _resendOTP() {
    if (widget.email.isNullOrEmpty) return;
    _authBloc.add(GetOTPForgotPasswordEvent(email: widget.email!));
  }

  Widget _buttonVerify() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: SizedBox(
          height: 50,
          child: PrimaryButton(
            text: 'Xác nhận',
            isDisable: !isEnableButton,
            onTap: isEnableButton ? _onSubmit : null,
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (otpCode.isNullOrEmpty || widget.email.isNullOrEmpty) return;
    _authBloc.add(SubmitVerifyOtpEvent(email: widget.email!, otp: otpCode));
  }
}

enum PhoneValidationState {
  none,
  valid,
  invalid,
}

class OTPInput extends StatefulWidget {
  const OTPInput({
    super.key,
    this.onVerify,
    this.otpValidationState = PhoneValidationState.none,
    this.onResetOTPState,
  });
  final Function(String otp)? onVerify;
  final VoidCallback? onResetOTPState;
  final PhoneValidationState otpValidationState;

  @override
  OTPInputState createState() => OTPInputState();
}

class OTPInputState extends State<OTPInput> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    // Auto focus to first OTP input field when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      }
    });
  }

  @override
  void didUpdateWidget(covariant OTPInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset OTP state if the widget is updated
    if (widget.otpValidationState != oldWidget.otpValidationState &&
        widget.otpValidationState == PhoneValidationState.none) {
      setState(() {
        // ignore: avoid_function_literals_in_foreach_calls
        _controllers.forEach((controller) => controller.clear());
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index].unfocus();
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index].unfocus();
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
    setState(() {});

    // Reset OTP state if any field is empty
    if (widget.otpValidationState != PhoneValidationState.none &&
        _controllers.any((controller) => controller.text.isEmpty)) {
      widget.onResetOTPState?.call();
    }

    // Check if last digit was filled and all fields are filled
    if (index == 5 && value.isNotEmpty) {
      final otp = _controllers.map((c) => c.text).join();
      if (otp.length == 6) {
        widget.onVerify?.call(otp);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 48,
          height: 64,
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(
              color: getColor(),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              counter: const SizedBox.shrink(),
              filled: true,
              fillColor: _focusNodes[index].hasFocus || _controllers[index].text.isNotEmpty
                  ? Colors.white
                  : Colors.grey.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _focusNodes[index].hasFocus || _controllers[index].text.isNotEmpty
                      ? getColor()
                      : Colors.grey.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: getColor()),
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              _onChanged(value, index);
            },
          ),
        );
      }),
    );
  }

  Color getColor() {
    switch (widget.otpValidationState) {
      case PhoneValidationState.none:
        return Colors.black54.withOpacity(0.5);
      case PhoneValidationState.valid:
        return Colors.green;
      case PhoneValidationState.invalid:
        return Colors.red;
    }
  }
}
