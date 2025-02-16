import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/data/provider/auth_provider.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import '../../../widgets/input_password_field.dart';
import '../../../widgets/primary_button.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChangePasswordBloc, ChangePasswordState>(
      listener: (context, state) {
        if (state is LoadingState) {
          showLoading(context);
        }
        if (state is SuccessState) {
          showMessage1OptionDialog(context, 'Đổi mật khẩu thành công', onClose: () {
            setState(() {
              _oldPassCon.clear();
              _newPassCon.clear();
              _confirmNewPassCon.clear();
            });
          });
        }
        if (state is FailureState) {
          showMessage1OptionDialog(context, state.errorMessage);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, size: 24, color: Colors.white)),
            centerTitle: true,
            title: const Text('Đổi mật khẩu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
                          if (_formKey.currentState!.validate() && _newPassCon.text.trim() == _confirmNewPassCon.text.trim()) {
                            BlocProvider.of<ChangePasswordBloc>(context).add(SubmitChange(oldPassword: _oldPassCon.text.trim(), newPassword: _newPassCon.text.trim()));
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

class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final _authProvider = AuthProvider();

  ChangePasswordBloc() : super(LoadingState()) {
    on((event, emit) async {
      if (event is Initialized) {
        emit(ValidateState());
      }
      if (event is SubmitChange) {
        emit(LoadingState());

        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          emit(const FailureState(errorMessage: 'No Internet Connection'));
        }
        final response = await _authProvider.changePassword(oldPass: event.oldPassword, newPass: event.newPassword, confPass: event.newPassword);

        if (response.isOK()) {
          emit(SuccessState());
        } else {
          emit(FailureState(errorMessage: response.errors?.first.errorMessage ?? 'Đổi mật khẩu thất bại'));
        }
      }
    });
  }
}

abstract class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object> get props => [];
}

class Initialized extends ChangePasswordEvent {}

class SubmitChange extends ChangePasswordEvent {
  final String oldPassword;
  final String newPassword;

  const SubmitChange({required this.oldPassword, required this.newPassword});

  @override
  List<Object> get props => [oldPassword, newPassword];
}

abstract class ChangePasswordState extends Equatable {
  const ChangePasswordState();

  @override
  List<Object> get props => [];
}

class ValidateState extends ChangePasswordState {}

class LoadingState extends ChangePasswordState {}

class SuccessState extends ChangePasswordState {}

class FailureState extends ChangePasswordState {
  final String errorMessage;

  const FailureState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
