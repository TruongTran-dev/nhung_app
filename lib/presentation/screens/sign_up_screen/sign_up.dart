import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/app/app_routes.dart';
import 'package:expensive_management/business/blocs/sign_up_bloc.dart';
import 'package:expensive_management/presentation/widgets/input_field.dart';
import 'package:expensive_management/presentation/widgets/input_password_field.dart';
import 'package:expensive_management/presentation/widgets/primary_button.dart';
import 'package:expensive_management/utils/screen_utilities.dart';

import 'sign_up_event.dart';
import 'sign_up_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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

  late SignUpBloc _signUpBloc;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _signUpBloc = BlocProvider.of<SignUpBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _signUpBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          showMessage1OptionDialog(
            context,
            'Đăng ký thành công, Vui lòng đăng nhập lại',
            buttonLabel: 'OK',
            onClose: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          );
        }
        if (state is SignUpFailed) {
          showMessage1OptionDialog(
            context,
            state.errorMessage,
            buttonLabel: 'OK',
            onClose: () {
              Navigator.pop(context);
              BlocProvider.of<SignUpBloc>(context).add(ValidateForm());
            },
          );
        }
        if (state is LoadingState) {
          showLoading(context);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16, top: padding.top, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: height - 150,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 60, bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset('images/logo_app.png', height: 150, width: 150, color: Theme.of(context).primaryColor),
                                Padding(
                                  padding: const EdgeInsets.only(top: 32),
                                  child: Text(
                                    'Chào mừng đăng ký ứng dụng',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                  ),
                  _signUpButton(context)
                ],
              ),
            ),
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
                BlocProvider.of<SignUpBloc>(context).add(SignUpSubmitted(
                  username: _usernameController.text.trim(),
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
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
                onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                child: Text('Đăng nhập', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14, fontStyle: FontStyle.italic)),
              )
            ],
          ),
        ],
      ),
    );
  }
}
