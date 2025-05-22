import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/features/auth/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:expensive_management/src/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/presentation/widgets/input_field.dart';
import 'package:expensive_management/presentation/widgets/primary_button.dart';
import 'package:expensive_management/src/shared/utils/app_constants.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isValid = false;
  late final AuthBloc _authBloc;

  @override
  void initState() {
    _authBloc = serviceLocator<AuthBloc>();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (FocusScope.of(context).hasFocus) {
          FocusScope.of(context).unfocus();
        }
      },
      child: BlocConsumer<AuthBloc, AuthState>(
        bloc: _authBloc,
        listener: (context, state) {
          if (state is GetOTPSuccessState) {
            context.push(AppRoutes.otp, extra: _emailController.text.trim());
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
      ),
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
          'Quên mật khẩu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppConstants.forgotPassword,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                  height: 1.4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 80, right: 16),
              child: Form(
                key: _formKey,
                onChanged: _validatorForm,
                child: SizedBox(
                  height: isValid ? 50 : 72,
                  child: Input(
                    textInputAction: TextInputAction.done,
                    controller: _emailController,
                    prefixIcon: Icons.mail_outline,
                    hint: 'Nhập địa chỉ email',
                    validator: (v) {
                      if (v == null || isNullOrEmpty(v)) {
                        return 'Địa chỉ email là bắt buộc';
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(v)) {
                        return 'Địa chỉ email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
            const Spacer(),
            _buttonSendCode(),
          ],
        ),
      ),
    );
  }

  void _validatorForm() {
    setState(() {
      isValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Widget _buttonSendCode() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: PrimaryButton(
        text: 'Gửi mã OTP',
        isDisable: !isValid,
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            _authBloc.add(GetOTPForgotPasswordEvent(email: _emailController.text.trim()));
          }
        },
      ),
    );
  }
}
