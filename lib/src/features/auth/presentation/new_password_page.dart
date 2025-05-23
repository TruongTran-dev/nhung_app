import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/auth/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:expensive_management/src/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/src/shared/widgets/input_password_field.dart';
import 'package:expensive_management/src/shared/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;
  const NewPasswordPage({super.key, required this.email});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isShowPassword = false;
  bool _isShowConfirmPassword = false;

  String messageValidate = '';
  bool hasCharacter = false;
  bool checkValidatePassword = false;

  final _formKey = GlobalKey<FormState>();
  late final AuthBloc _authBloc;

  @override
  void initState() {
    _authBloc = serviceLocator<AuthBloc>();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      _authBloc.add(SubmitNewPasswordEvent(
        email: widget.email,
        password: _passwordController.text,
      ));
    }
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
          switch (state.runtimeType) {
            case UpdateNewPasswordSuccessState:
              AppUtils.showSnackBar(context, 'Cập nhật mật khẩu thành công. Vui lòng đăng nhập lại');
              GoRouter.of(context).popUntil(AppRoutes.login);
              break;
            case UpdateNewPasswordFailedState:
              final errorState = state as UpdateNewPasswordFailedState;
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
              isLoading ? const Positioned.fill(child: LoadingWidget()) : const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }

  Widget _body() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0.5,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        leading: InkWell(
          onTap: context.pop,
          child: const Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.white),
        ),
        title: const Text(
          'Mật khẩu mới',
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
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                        child: Icon(Icons.password_outlined, size: 80, color: Theme.of(context).primaryColor),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Thiết lập mật khẩu mới để hoàn tất khôi phục tài khoản của bạn',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: InputPasswordField(
                          controller: _passwordController,
                          keyboardType: TextInputType.text,
                          hint: 'Mật khẩu mới',
                          obscureText: !_isShowPassword,
                          onTapSuffixIcon: () {
                            setState(() {
                              _isShowPassword = !_isShowPassword;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (value.isNotEmpty && value.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            } else if (value.length > 40) {
                              return 'Mật khẩu không được quá 40 ký tự';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: InputPasswordField(
                          controller: _confirmPasswordController,
                          keyboardType: TextInputType.text,
                          hint: 'Xác nhận mật khẩu mới',
                          obscureText: !_isShowConfirmPassword,
                          onTapSuffixIcon: () {
                            setState(() => _isShowConfirmPassword = !_isShowConfirmPassword);
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập xác nhận mật khẩu';
                            }
                            if (value.isNotEmpty && value.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            } else if (value.length > 40) {
                              return 'Mật khẩu không được quá 40 ký tự';
                            } else if (value != _passwordController.text) {
                              return 'Mật khẩu và xác nhận mật khẩu phải giống nhau';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buttonSendCode()
          ],
        ),
      ),
    );
  }

  Widget _buttonSendCode() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      child: PrimaryButton(
        text: 'Lưu mật khẩu',
        onTap: _onSubmit,
      ),
    );
  }
}
