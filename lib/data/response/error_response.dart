class Errors {
  final String? errorCode;
  final String? errorMessage;
  final dynamic stackFrames;

  Errors({
    this.errorCode,
    this.errorMessage,
    this.stackFrames,
  });

  factory Errors.fromJson(Map<String, dynamic> json) => Errors(
    errorCode: json['errorCode'],
    errorMessage: json['errorMessage'],
    stackFrames: json['stackFrames'],
  );

  @override
  String toString() {
    return 'Errors{errorCode: $errorCode, errorMessage: $errorMessage, stackFrames: $stackFrames}';
  }
}