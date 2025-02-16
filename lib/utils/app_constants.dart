class AppConstants {
  static const String isRememberInfo = 'REMEMBER_INFO';
  static const String isLoggedOut = 'IS_LOGGED_OUT';
  static const String passwordExpireTimeKey = 'PASSWORD_EXPIRE_TIME';
  static const String refreshTokenKey = 'REFRESH_TOKEN';
  static const String refreshTokenExpiredKey = 'REFRESH_TOKEN_EXPIRED';
  static const String accessTokenKey = 'ACCESS_TOKEN';
  static const String accessTokenExpiredTimeKey = 'ACCESS_TOKEN_EXPIRED';
  static const String usernameKey = 'USERNAME';
  static const String emailKey = 'EMAIL';

  static const String firstTimeOpenKey = 'FIRST_TIME_OPEN';
  static const String agreedWithTermsKey = 'AGREED_WITH_TERMS';

  static const String itemId = 'ITEM_SELECTED_ID';
  static const String itemLeading = 'ITEM_SELECTED_LEADING';
  static const String itemTitle = 'ITEM_SELECTED_TITLE';

  static const String currencyKey = 'CURRENCY';
  static const String isHiddenAmount = 'HIDDEN_AMOUNT';

  static const String fcmTokenKey = 'FCM_TOKEN_KEY';

  static RegExp emailExp = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
  static RegExp passwordExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$');

  static const String exitApp = 'Bạn muốn thoát khỏi ứng dụng?';

  static const String forgotPassword = 'Nếu bạn không nhớ mật khẩu tài khoản của mình.\nNhập địa chỉ email mà bạn đã đăng ký tài khoản vào ô bên dưới, chúng tôi sẽ gửi một mã OTP đến địa chỉ email đó giúp bạn khôi phục lại mật khẩu tài khoản của mình.';
  static const String noInternetTitle = 'Opss!, Không có kết nối mạng';
  static const String noInternetContent = 'Vui lòng kiểm tra lại đường truyền mạng của bạn hoặc kết hối với wi-fi';

  static const String mathReport = 'Ghi chép này sẽ không được thống kê vào báo cáo';

  static const String contentDeleteWallet = 'Nếu bạn xóa tài khoản này, tất cả dữ liệu liên quan cũng sẽ bị xóa. Dữ liệu sau khi xóa sẽ không khôi phục được.';

  static const String wrong = 'Something went wrong, Please try again later.';

}
