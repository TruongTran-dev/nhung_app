import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/auth/domain/repos/auth_repo.dart';

class VerifyOtpUseCase extends UseCase<bool, VerifyOtpParams> {
  final AuthRepo authRepo;

  VerifyOtpUseCase({required this.authRepo});

  @override
  Future<Either<Failure, bool>> call(VerifyOtpParams params) async {
    return await authRepo.verifyOtp(data: params.toMap());
  }
}

class VerifyOtpParams extends Equatable {
  final String email;
  final String otp;

  const VerifyOtpParams({
    required this.email,
    required this.otp,
  });

  @override
  List<Object> get props => [email, otp];

  @override
  bool get stringify => true;

  VerifyOtpParams copyWith({
    String? email,
    String? otp,
  }) {
    return VerifyOtpParams(
      email: email ?? this.email,
      otp: otp ?? this.otp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}
