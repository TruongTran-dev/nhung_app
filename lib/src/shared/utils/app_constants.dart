class AppConstants {
  static const String isLoggedOut = 'IS_LOGGED_OUT';
  static const String passwordExpireTimeKey = 'PASSWORD_EXPIRE_TIME';
  static const String refreshTokenKey = 'REFRESH_TOKEN';
  static const String refreshTokenExpiredKey = 'REFRESH_TOKEN_EXPIRED';
  static const String accessTokenKey = 'ACCESS_TOKEN';
  static const String accessTokenExpiredTimeKey = 'ACCESS_TOKEN_EXPIRED';
  static const String usernameKey = 'USERNAME';
  static const String emailKey = 'EMAIL';

  




  static const String currencyKey = 'CURRENCY';
  static const String isHiddenAmount = 'HIDDEN_AMOUNT';


  static RegExp emailExp = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
  static RegExp passwordExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$');

  static const String exitApp = 'Bạn có muốn thoát ứng dụng?';

  static const String forgotPassword = 'Nếu bạn không nhớ mật khẩu tài khoản của mình.\nNhập địa chỉ email mà bạn đã đăng ký tài khoản vào ô bên dưới, chúng tôi sẽ gửi một mã OTP đến địa chỉ email đó giúp bạn khôi phục lại mật khẩu tài khoản của mình.';
  static const String noInternetTitle = 'Opss!, Không có kết nối mạng';
  static const String noInternetContent = 'Vui lòng kiểm tra lại đường truyền mạng của bạn hoặc kết hối với wi-fi';

  static const String mathReport = 'Ghi chép này sẽ không được thống kê vào báo cáo';

  static const String contentDeleteWallet = 'Nếu bạn xóa tài khoản này, tất cả dữ liệu liên quan cũng sẽ bị xóa. Dữ liệu sau khi xóa sẽ không khôi phục được.';

  static const String wrong = 'Something went wrong, Please try again later.';

}
