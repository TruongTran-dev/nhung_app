import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/features/auth/domain/models/user_model.dart';
import 'package:expensive_management/src/features/auth/domain/usecases/change_pwd.dart';
import 'package:expensive_management/src/features/auth/domain/usecases/get_otp_forgot_pwd.dart';
import 'package:expensive_management/src/features/auth/domain/usecases/login.dart';
import 'package:expensive_management/src/features/auth/domain/usecases/register.dart';
import 'package:expensive_management/src/features/auth/domain/usecases/update_new_pwd.dart';
import 'package:expensive_management/src/features/auth/domain/usecases/verify_otp.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'state.dart';
part 'event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetOtpForgotPwdUseCase getOtpForgotPwdUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final UpdateNewPwdUseCase updateNewPwdUseCase;
  final ChangePwdUseCase changePwdUseCase;
  final AppPrefStorage appPrefStorage;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.getOtpForgotPwdUseCase,
    required this.verifyOtpUseCase,
    required this.updateNewPwdUseCase,
    required this.changePwdUseCase,
    required this.appPrefStorage,
  }) : super(AuthInitial()) {
    on<ReValidateFormEvent>((event, emit) => emit(AuthInitial()), transformer: droppable());
    on<SubmitLoginEvent>(_onSubmitLoginEvent, transformer: droppable());
    on<RegisterEvent>(_onRegisterEvent, transformer: droppable());
    on<GetOTPForgotPasswordEvent>(_onGetOTPForgotPasswordEvent, transformer: droppable());
    on<SubmitVerifyOtpEvent>(_onSubmitVerifyOtpEvent, transformer: droppable());
    on<SubmitNewPasswordEvent>(_onSubmitNewPasswordEvent, transformer: droppable());
    on<ChangePasswordEvent>(_onChangePasswordEvent, transformer: droppable());
  }

  Future<void> _onSubmitLoginEvent(SubmitLoginEvent event, Emitter<AuthState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(LoadingState());
    });

    final response = await loginUseCase.call(
      LoginParams(
        username: event.username,
        password: event.password,
        fcmToken: event.deviceToken.isNullOrEmpty ? null : event.deviceToken,
      ),
    );

    if (response.isLeft) {
      final error = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(LoginFailedState(errorMessage: error.message));
      });
      return;
    }

    final data = response.right;
    final userData = data['data'];
    if (data['httpStatus'] == 200 && userData is Map) {
      await appPrefStorage.setSaveUserInfo(UserModel.fromJson(userData.cast<String, dynamic>()));
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(LoginSuccessState());
      });
    } else {
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(LoginFailedState(errorMessage: data['message']));
      });
    }
  }

  Future<void> _onRegisterEvent(RegisterEvent event, Emitter<AuthState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(LoadingState());
    });

    final response = await registerUseCase.call(
      RegisterParams(
        username: event.username,
        password: event.password,
        email: event.email,
      ),
    );

    if (response.isLeft) {
      final error = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(RegisterFailedState(errorMessage: error.message));
      });
      return;
    }

    final data = response.right;
    if (data['httpStatus'] == 200) {
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(RegisterSuccessState());
      });
    } else {
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(RegisterFailedState(errorMessage: data['message']));
      });
    }
  }

  Future<void> _onGetOTPForgotPasswordEvent(GetOTPForgotPasswordEvent event, Emitter<AuthState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(LoadingState());
    });

    final response = await getOtpForgotPwdUseCase.call(event.email);

    if (response.isLeft) {
      final error = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(GetOTPFailedState(errorMessage: error.message));
      });
      return;
    }

    if (response.right) {
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(GetOTPSuccessState());
      });
    } else {
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(GetOTPFailedState(errorMessage: "Không thể gửi OTP đến email này"));
      });
    }
  }

  Future<void> _onSubmitVerifyOtpEvent(SubmitVerifyOtpEvent event, Emitter<AuthState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(LoadingState());
    });

    final response = await verifyOtpUseCase.call(
      VerifyOtpParams(email: event.email, otp: event.otp),
    );

    if (response.isLeft) {
      final error = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(OTPVerifyFailedState(
          errorCode: error is ServerError ? error.key : error.statusCode.toString(),
          errorMessage: error.message,
        ));
      });
      return;
    }

    if (response.right) {
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(OTPVerifySuccessState());
      });
    } else {
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(OTPVerifyFailedState(errorMessage: "Mã OTP không hợp lệ", errorCode: "400"));
      });
    }
  }

  Future<void> _onSubmitNewPasswordEvent(SubmitNewPasswordEvent event, Emitter<AuthState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(LoadingState());
    });

    final response = await updateNewPwdUseCase.call(
      UpdateNewPwdParams(email: event.email, password: event.password),
    );

    if (response.isLeft) {
      final error = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(UpdateNewPasswordFailedState(
          key: error is ServerError ? error.key : error.statusCode.toString(),
          errorMessage: error.message,
        ));
      });
      return;
    }

    if (response.right) {
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(UpdateNewPasswordSuccessState());
      });
    } else {
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(UpdateNewPasswordFailedState(
          key: "400",
          errorMessage: "Mã OTP không hợp lệ",
        ));
      });
    }
  }

  Future<void> _onChangePasswordEvent(ChangePasswordEvent event, Emitter<AuthState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(LoadingState());
    });

    final response = await changePwdUseCase.call(
      ChangePwdParams(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      ),
    );

    if (response.isLeft) {
      final error = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(ChangePasswordFailedState(
          key: error is ServerError ? error.key : error.statusCode.toString(),
          errorMessage: error.message,
        ));
      });
      return;
    }

    if (response.right) {
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(ChangePasswordSuccessState());
      });
    } else {
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(ChangePasswordFailedState(
          key: "400",
          errorMessage: "error occurred while changing password",
        ));
      });
    }
  }
}
