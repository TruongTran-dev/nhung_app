class ApiPath {
  //Change ip your ipv4 with command ipconfig in cmd (macOs), ipconfig/all in cmd (window)
  static const String apiDomain = 'http://192.168.1.181:8081';

  static const String signup = '/api/auth/sign-up';

  static const String signIn = '/api/auth/sign-in';

  static const String changePassword = '/api/auth/change-password';

  static const String forgotPassword = '/api/auth/forgot-password';

  static const String newPassword = '/api/auth/new-password';

  static const String refreshToken = '/api/auth/refresh-token';

  static const String sendOtp = '/api/auth/send-otp';

  static const String getAllListCategory = '/api/v1/category/all';

  static const String apiCategory = '/api/v1/category';

  static const String apiLogoCategory = '/api/v1/category-logo';

  static const String categoryReport = '/api/v1/report/category-report';

  static const String weekReport = '/api/v1/report/week-report';

  static const String wallet = '/api/v1/wallet';

  static const String transaction = '/api/v1/transaction';

  static const String getReportByWalletId = '/api/v1/report/?fromDate={fromDate}&toDate={toDate}&walletId={walletId}';

  static const String getReport = '/api/v1/report';

  static const String expenseLimit = '/api/v1/expense-limit';

  static const String recurring = '/api/v1/recurring-transaction';

  static const String exportData = '/api/v1/export';

  static const String analyticReport = '/api/v1/report/statistic';
}
