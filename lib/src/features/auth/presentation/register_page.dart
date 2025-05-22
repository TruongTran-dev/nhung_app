import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/features/auth/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';
import 'package:expensive_management/src/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/presentation/widgets/input_field.dart';
import 'package:expensive_management/presentation/widgets/input_password_field.dart';
import 'package:expensive_management/presentation/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isShowPassword = false;
  bool _isShowConfirmPassword = false;

  String messageValidate = '';
  String messageValidateEmail = '';
  bool hasCharacter = false;
  bool checkValidate = false;
  bool errorEmail = false;
  bool errorPassword = false;

  late AuthBloc _authBloc;
  final _formKey = GlobalKey<FormState>();
  bool isValidForm = false;

  @override
  void initState() {
    super.initState();
    _authBloc = serviceLocator<AuthBloc>();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _unFocus() {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }
  }

  void _validateForm() {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unFocus,
      child: Scaffold(
        body: BlocConsumer<AuthBloc, AuthState>(
          bloc: _authBloc,
          listener: (context, state) {
            switch (state.runtimeType) {
              case RegisterSuccessState:
                showMessage1OptionDialog(
                  context,
                  'Đăng ký thành công, Vui lòng đăng nhập lại',
                  buttonLabel: 'OK',
                  onClose: () {
                    GoRouter.of(context).popUntil(AppRoutes.login);
                  },
                );
                break;
              case RegisterFailedState:
                showMessage1OptionDialog(
                  context,
                  (state as RegisterFailedState).errorMessage,
                  buttonLabel: 'OK',
                  onClose: () {
                    _authBloc.add(ReValidateFormEvent());
                  },
                );
                break;
              default:
                break;
            }
            // if (state is SignUpSuccess) {
            //   showMessage1OptionDialog(
            //     context,
            //     'Đăng ký thành công, Vui lòng đăng nhập lại',
            //     buttonLabel: 'OK',
            //     onClose: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
            //   );
            // }
            // if (state is SignUpFailed) {
            //   showMessage1OptionDialog(
            //     context,
            //     state.errorMessage,
            //     buttonLabel: 'OK',
            //     onClose: () {
            //       Navigator.pop(context);
            //       BlocProvider.of<SignUpBloc>(context).add(ValidateForm());
            //     },
            //   );
            // }
            // if (state is LoadingState) {
            //   showLoading(context);
            // }
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
      ),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Container(
        height: context.screenSize.height,
        padding: EdgeInsets.only(left: 16, top: 60, right: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Form(
              key: _formKey,
              onChanged: _validateForm,
              child: Column(
                children: [
                  Image.asset(
                    'images/logo_app.png',
                    height: 150,
                    width: 150,
                    color: Theme.of(context).primaryColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24, right: 40, left: 40),
                    child: Text(
                      'Đăng ký ngay để quản lý chi tiêu thông minh',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).primaryColor,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Input(
                      hint: 'Tên đăng nhập',
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên đăng nhập';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Input(
                      hint: 'Địa chỉ email',
                      controller: _emailController,
                      keyboardType: TextInputType.text,
                      prefixIcon: Icons.mail_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập địa chỉ email';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: InputPasswordField(
                      hint: 'Mật khẩu',
                      controller: _passwordController,
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
                      hint: 'Xác nhận mật khẩu',
                      controller: _confirmPasswordController,
                      obscureText: !_isShowConfirmPassword,
                      onTapSuffixIcon: () {
                        setState(() {
                          _isShowConfirmPassword = !_isShowConfirmPassword;
                        });
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
            const Spacer(),
            _signUpButton(context)
          ],
        ),
      ),
    );
  }

  Widget _signUpButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PrimaryButton(
            text: 'Đăng ký',
            onTap: () async {
              if (_formKey.currentState!.validate()) {
                _authBloc.add(RegisterEvent(
                  username: _usernameController.text.trim(),
                  password: _passwordController.text.trim(),
                  email: _emailController.text.trim(),
                ));
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Bạn đã có tài khoản? ', style: TextStyle(fontSize: 14)),
              GestureDetector(
                onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
