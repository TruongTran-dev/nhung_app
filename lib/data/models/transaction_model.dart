class Transaction {
  final String? id;
  final int? amount;
  final String? categoryId;
  final String? categoryName;
  final String? categoryLogo;
  final String? description;
  final DateTime? ariseDate;
  final String? walletId;
  final String? walletName;
  final bool? addToReport;
  final String? transactionType;
  final String? imageUrl;
  final DateTime? createdAt;
  final int? createdBy;

  Transaction({
    this.id,
    this.amount,
    this.categoryId,
    this.categoryName,
    this.categoryLogo,
    this.description,
    this.ariseDate,
    this.walletId,
    this.walletName,
    this.addToReport,
    this.transactionType,
    this.imageUrl,
    this.createdAt,
    this.createdBy,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String?,
      amount: json['amount'] as int?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      categoryLogo: json['categoryLogo'] as String?,
      description: json['description'] as String?,
      ariseDate: json['ariseDate'] == null
          ? null
          : DateTime.parse(json['ariseDate'] as String),
      walletId: json['walletId'] as String?,
      walletName: json['walletName'] as String?,
      addToReport: json['addToReport'] as bool?,
      transactionType: json['transactionType'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as int?,
    );
  }
}
