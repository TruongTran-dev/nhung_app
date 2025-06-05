import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/auth/presentation/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/src/shared/widgets/input_password_field.dart';
import 'package:expensive_management/src/shared/widgets/primary_button.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPassCon = TextEditingController();
  final _newPassCon = TextEditingController();
  final _confirmNewPassCon = TextEditingController();

  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  final _formKey = GlobalKey<FormState>();
  final _authBloc = serviceLocator<AuthBloc>();

  void _clearSession() {
    _oldPassCon.clear();
    _newPassCon.clear();
    _confirmNewPassCon.clear();
    _showOld = false;
    _showNew = false;
    _showConfirm = false;
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      bloc: _authBloc,
      listener: (context, state) {
        if (state is ChangePasswordSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đổi mật khẩu thành công, vui lòng đăng nhập lại')),
          );
          _clearSession();
          AppUtils.logout(context: context);
          // Navigator.pop(context);
        } else if (state is ChangePasswordFailedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, size: 24, color: Colors.white),
            ),
            centerTitle: true,
            title: const Text(
              'Đổi mật khẩu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: InputPasswordField(
                        controller: _oldPassCon,
                        hint: 'Mật khẩu cũ',
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        obscureText: !_showOld,
                        onTapSuffixIcon: () {
                          setState(() {
                            _showOld = !_showOld;
                          });
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu cũ';
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
                        controller: _newPassCon,
                        hint: 'Mật khẩu mới',
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        obscureText: !_showNew,
                        onTapSuffixIcon: () {
                          setState(() {
                            _showNew = !_showNew;
                          });
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu mới';
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
                        controller: _confirmNewPassCon,
                        hint: 'Xác nhận mật khẩu mới',
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        obscureText: !_showConfirm,
                        onTapSuffixIcon: () {
                          setState(() {
                            _showConfirm = !_showConfirm;
                          });
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập xác nhận mật khẩu mới';
                          }
                          if (value.isNotEmpty && value.length < 6) {
                            return 'Mật khẩu phải có ít nhất 6 ký tự';
                          } else if (value.length > 40) {
                            return 'Mật khẩu không được quá 40 ký tự';
                          } else if (value != _newPassCon.text) {
                            return 'Mật khẩu và xác nhận mật khẩu phải giống nhau';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 30, 0, 16),
                      child: PrimaryButton(
                        text: 'Đổi mật khẩu',
                        onTap: () async {
                          if (_formKey.currentState!.validate() &&
                              _newPassCon.text.trim() == _confirmNewPassCon.text.trim()) {
                            _authBloc.add(ChangePasswordEvent(
                              oldPassword: _oldPassCon.text.trim(),
                              newPassword: _newPassCon.text.trim(),
                            ));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
