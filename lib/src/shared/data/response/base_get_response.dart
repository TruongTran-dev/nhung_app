import 'dart:io';

class BaseGetResponse {
  final int? pageNumber;
  final int? pageSize;
  final int? totalRecord;
  final int? status;
  final String? error;

  BaseGetResponse({
    this.status,
    this.error,
    this.pageNumber,
    this.pageSize,
    this.totalRecord,
  });

  BaseGetResponse.withHttpError({
    this.status,
    this.error,
    this.pageNumber,
    this.pageSize,
    this.totalRecord,
  });

  factory BaseGetResponse.fromJson(Map<String, dynamic> json) {
    return BaseGetResponse(
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      totalRecord: json['totalRecord'],
      status: json['status'],
      error: json['error'],
    );
  }

  @override
  String toString() {
    return 'BaseGetResponse{pageNumber: $pageNumber, pageSize: $pageSize, totalRecord: $totalRecord, status: $status, error: $error}';
  }

  bool isOK() {
    return status == HttpStatus.ok;
  }

  bool isFailure() {
    return status != HttpStatus.ok;
  }
}

class ExpiredTokenGetResponse extends BaseGetResponse {
  ExpiredTokenGetResponse()
      : super(
          status: HttpStatus.unauthorized,
          error: 'Token Expired !',
        );
}
