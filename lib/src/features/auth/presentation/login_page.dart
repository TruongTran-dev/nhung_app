import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/features/auth/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/features/planning_expenditure_analysis/analytics.dart';
import 'package:expensive_management/src/shared/services/notification_service.dart';
import 'package:expensive_management/src/shared/widgets/input_field.dart';
import 'package:expensive_management/src/shared/widgets/input_password_field.dart';
import 'package:expensive_management/src/shared/widgets/primary_button.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:expensive_management/src/shared/widgets/loading_widget.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isShowPassword = false;

  final _formKey = GlobalKey<FormState>();
  late final AuthBloc _authBloc;
  String? _deviceToken;

  @override
  void initState() {
    _authBloc = serviceLocator<AuthBloc>();
    _usernameController.text = 'nhungchan';
    _passwordController.text = '123456';
    _deviceToken = serviceLocator<NotificationService>().token;
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
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
      child: Scaffold(
        body: BlocConsumer<AuthBloc, AuthState>(
          bloc: _authBloc,
          listener: (context, state) {
            switch (state.runtimeType) {
              case LoginFailedState:
                showMessage1OptionDialog(
                  context,
                  (state as LoginFailedState).errorMessage,
                  buttonLabel: 'OK',
                  onClose: () {
                    _authBloc.add(ReValidateFormEvent());
                  },
                );
                break;
              case LoginSuccessState:
                final uniqueKey = GlobalExtensions.generateRandomKey();
                context.go(AppRoutes.home, extra: uniqueKey);
                break;
              default:
                break;
            }
          },
          builder: (context, state) {
            final isLoading = state is LoadingState;
            return Stack(
              children: [
                Form(
                  key: _formKey,
                  child: _loginForm(context),
                ),
                isLoading ? Positioned.fill(child: const LoadingWidget()) : const SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _loginForm(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: SizedBox(
        height: context.screenSize.height,
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _appIcon(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Input(
                      textInputAction: TextInputAction.next,
                      controller: _usernameController,
                      focusNode: FocusNode(),
                      onChanged: (text) {},
                      keyboardType: TextInputType.text,
                      hint: 'Tên đăng nhập',
                      prefixIcon: Icons.email_outlined,
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
                    child: InputPasswordField(
                      controller: _passwordController,
                      onChanged: (text) {},
                      keyboardType: TextInputType.text,
                      hint: 'Mật khẩu',
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        GestureDetector(
                          onTap: _navToForgotPassword,
                          child: Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.italic,
                              color: context.theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _logInButton(),
          ],
        ),
      ),
    );
  }

  Widget _logInButton() {
    return Container(
      width: context.screenSize.width,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PrimaryButton(
            text: 'Đăng nhập',
            onTap: () {
              // Unfocus current field if any has focus
              FocusScope.of(context).unfocus();

              if (_formKey.currentState!.validate()) {
                _authBloc.add(
                  SubmitLoginEvent(
                    username: _usernameController.text,
                    password: _passwordController.text,
                    deviceToken: _deviceToken,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Chưa có tài khoản? ', style: TextStyle(fontSize: 14)),
              GestureDetector(
                onTap: () {
                  context.push(AppRoutes.register);
                },
                child: Text(
                  ' Đăng ký',
                  style: TextStyle(color: context.theme.primaryColor, fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _appIcon() => Padding(
        padding: const EdgeInsets.only(top: 80, bottom: 20),
        child: Column(
          children: [
            Image.asset(
              'images/logo_app.png',
              width: 150,
              height: 160,
              color: context.theme.primaryColor,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
              child: Text(
                'Quản lý chi tiêu thông minh - Tương lai tài chính vững vàng',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: context.theme.primaryColor,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      );

  void _navToForgotPassword() => context.push(AppRoutes.forgotPwd);
}
