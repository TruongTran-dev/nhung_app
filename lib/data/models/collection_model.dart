class CollectionModel {
  final int? id;
  final double? amount;
  final int? categoryId;
  final String? categoryName;
  final String? categoryLogo;
  final String? description;
  final String? ariseDate;
  final int? walletId;
  final String? walletName;
  final String? walletType;
  final bool? addToReport;
  final String? transactionType;
  final String? imageUrl;
  final String? createdAt;
  final int? createdBy;

  CollectionModel({
    this.id,
    this.amount,
    this.categoryId,
    this.categoryLogo,
    this.categoryName,
    this.description,
    this.ariseDate,
    this.walletId,
    this.walletName,
    this.walletType,
    this.addToReport,
    this.transactionType,
    this.imageUrl,
    this.createdAt,
    this.createdBy,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) =>
      CollectionModel(
        id: json['id'],
        amount: double.tryParse(json['amount'].toString()),
        categoryId: json['categoryId'],
        categoryName: json['categoryName'],
        categoryLogo: json['categoryLogo'],
        description: json['description'],
        ariseDate: json['ariseDate'],
        walletId: json['walletId'],
        walletName: json['walletName'],
        walletType: json["walletType"],
        addToReport: json['addToReport'],
        transactionType: json['transactionType'],
        imageUrl: json['imageUrl'],
        createdAt: json['createdAt'],
        createdBy: json['createdBy'],
      );

  @override
  String toString() {
    return 'CollectionModel{id: $id, amount: $amount, categoryId: $categoryId, categoryName: $categoryName, categoryLogo: $categoryLogo, description: $description, ariseDate: $ariseDate, walletId: $walletId, walletName: $walletName, walletType: $walletType, addToReport: $addToReport, transactionType: $transactionType, imageUrl: $imageUrl, createdAt: $createdAt, createdBy: $createdBy}';
  }
}
