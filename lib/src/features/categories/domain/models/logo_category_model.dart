import 'package:equatable/equatable.dart';

class LogoCategoryModel extends Equatable {
  final int id;
  final String fileUrl;
  final String fileName;
  final String createdAt;
  final String createdById;

  const LogoCategoryModel({
    required this.id,
    required this.fileUrl,
    required this.fileName,
    required this.createdAt,
    required this.createdById,
  });

  @override
  List<Object?> get props => [
        id,
        fileUrl,
        fileName,
        createdAt,
        createdById,
      ];
  @override
  bool get stringify => true;

  factory LogoCategoryModel.fromJson(Map<String, dynamic> json) => LogoCategoryModel(
        id: json['id'],
        fileUrl: json['fileUrl'],
        fileName: json['fileName'],
        createdAt: json['createdAt'],
        createdById: json['createdBy'].toString(),
      );

  @override
  String toString() {
    return 'LogoCategoryModel{id: $id, fileUrl: $fileUrl, fileName: $fileName, createdAt: $createdAt, createdById: $createdById}';
  }
}
