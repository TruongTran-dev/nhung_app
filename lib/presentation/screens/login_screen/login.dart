import 'package:expensive_management/app/app_routes.dart';
import 'package:expensive_management/business/blocs/login_bloc.dart';
import 'package:expensive_management/business/blocs/sign_up_bloc.dart';
import 'package:expensive_management/presentation/screens/login_screen/login_event.dart';
import 'package:expensive_management/presentation/screens/login_screen/login_state.dart';
import 'package:expensive_management/presentation/screens/planning_screen/expenditure_analysis/analytics.dart';
import 'package:expensive_management/presentation/screens/sign_up_screen/sign_up.dart';
import 'package:expensive_management/presentation/widgets/input_field.dart';
import 'package:expensive_management/presentation/widgets/input_password_field.dart';
import 'package:expensive_management/presentation/widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isShowPassword = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _usernameController.text = 'test';
    _passwordController.text = '123456';
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
      onTap: () => FocusScope.of(context).unfocus(),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoadingState) {
            showLoading(context);
          }
          if (state is LoginFailed) {
            showMessage1OptionDialog(
              context,
              state.errorMessage,
              buttonLabel: 'OK',
              onClose: () {
                Navigator.pop(context);
                BlocProvider.of<LoginBloc>(context).add(ValidateForm());
              },
            );
          }
          if (state is LoginSuccess) {
            Navigator.pushNamed(context, AppRoutes.home);
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                    child: Form(key: _formKey, child: _loginForm(context))),
              ),
              Positioned(bottom: 0, child: _logInButton(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _appIcon(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Input(
            textInputAction: TextInputAction.next,
            controller: _usernameController,
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
                onTap: () => _navToForgotPassword(context),
                child: Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _logInButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PrimaryButton(
            text: 'Đăng nhập',
            onTap: () {
              if (_formKey.currentState!.validate()) {
                BlocProvider.of<LoginBloc>(context).add(LoginSubmitted(
                  username: _usernameController.text.trim(),
                  password: _passwordController.text.trim(),
                ));
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BlocProvider<SignUpBloc>(
                              create: (_) => SignUpBloc(),
                              child: const SignUpPage())));
                },
                child: Text(' Đăng ký ngay',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 14,
                        fontStyle: FontStyle.italic)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _appIcon() => Padding(
        padding: const EdgeInsets.only(top: 120, bottom: 30),
        child: Column(
          children: [
            Image.asset('images/logo_app.png',
                width: 150, height: 160, color: Theme.of(context).primaryColor),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'Vui lòng đăng nhập!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).primaryColor,
                    fontSize: 20),
              ),
            ),
          ],
        ),
      );

  _navToForgotPassword(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.forgotPassword);
}
