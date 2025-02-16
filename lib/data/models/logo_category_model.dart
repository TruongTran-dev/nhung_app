class LogoCategoryModel {
  final int? id;
  final String? fileUrl;
  final String? fileName;
  final String? createdAt;
  final String? createdById;

  LogoCategoryModel({
    this.id,
    this.fileUrl,
    this.fileName,
    this.createdAt,
    this.createdById,
  });

  factory LogoCategoryModel.fromJson(Map<String, dynamic> json) =>
      LogoCategoryModel(
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
