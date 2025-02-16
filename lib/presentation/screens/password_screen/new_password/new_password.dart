import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/business/blocs/login_bloc.dart';
import 'package:expensive_management/data/provider/auth_provider.dart';
import 'package:expensive_management/presentation/screens/login_screen/login.dart';
import 'package:expensive_management/presentation/widgets/animation_loading.dart';
import 'package:expensive_management/presentation/widgets/input_password_field.dart';
import 'package:expensive_management/presentation/widgets/primary_button.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';
import 'package:expensive_management/utils/screen_utilities.dart';

import 'new_password_bloc.dart';
import 'new_password_event.dart';
import 'new_password_state.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;
  const NewPasswordPage({Key? key, required this.email}) : super(key: key);

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final focusNode = FocusNode();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isShowPassword = false;
  bool _isShowConfirmPassword = false;

  String messageValidate = '';
  bool hasCharacter = false;
  bool checkValidatePassword = false;

  late NewPasswordBloc _newPasswordBloc;

  final _authProvider = AuthProvider();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _newPasswordBloc = BlocProvider.of<NewPasswordBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewPasswordBloc, NewPasswordState>(
      listenWhen: (previousState, currentState) {
        return currentState.apiError != ApiError.noError;
      },
      listener: (context, state) {
        if (state.apiError == ApiError.internalServerError) {
          showMessage1OptionDialog(context, 'error', content: 'internal_server_error');
        }
        if (state.apiError == ApiError.noInternetConnection) {
          showMessageNoInternetDialog(context);
        }
      },
      builder: (context, state) {
        Widget body = const SizedBox.shrink();
        if (state.isLoading) {
          body = const Scaffold(body: AnimationLoading());
        } else {
          body = _body(state);
        }
        return body;
      },
    );
  }

  Widget _body(NewPasswordState state) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0.5,
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.white)),
          title: const Text('Mật khẩu mới', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
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
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: Icon(Icons.password_outlined, size: 100, color: Theme.of(context).primaryColor),
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
      ),
    );
  }

  Widget _buttonSendCode() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      child: PrimaryButton(
        text: 'Thiết lập',
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            final connectivityResult = await Connectivity().checkConnectivity();
            if (connectivityResult == ConnectivityResult.none && mounted) {
              showMessageNoInternetDialog(context);
            } else {
              _newPasswordBloc.add(DisplayLoading());
              final response = await _authProvider.newPassword(
                email: widget.email,
                password: _passwordController.text.trim(),
                confirmPassword: _confirmPasswordController.text.trim(),
              );
              if (response.isOK() && mounted) {
                _newPasswordBloc.add(OnSuccess());
                showMessage1OptionDialog(
                  context,
                  'Thiết lập mật khẩu mới thành công',
                  content: 'Vui lòng đăng nhập lại với mật khẩu mới.',
                  buttonLabel: 'Đăng nhập',
                  onClose: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(create: (context) => LoginBloc(), child: const LoginPage()),
                      ),
                    );
                  },
                );
              } else {
                _newPasswordBloc.add(OnFailure());
                showMessage1OptionDialog(
                  context,
                  response.errors?.first.errorMessage,
                );
              }
            }
          }
        },
      ),
    );
  }
}
