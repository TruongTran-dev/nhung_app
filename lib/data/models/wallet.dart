class Wallet {
  final int? id;
  final double? accountBalance;
  final String? name;
  final String? accountType;
  final String? currency;
  final String? description;
  final String? createdAt;
  final int? createdBy;
  final bool report;

  ///using for checkList in select category in limit_expenditure
  bool isChecked;

  Wallet({
    this.id,
    this.accountBalance,
    this.name,
    this.accountType,
    this.currency,
    this.description,
    this.createdAt,
    this.createdBy,
    this.report = false,
    this.isChecked = false,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      accountBalance: json['accountBalance'],
      name: json['name'],
      accountType: json['accountType'],
      currency: json['currency'] ?? '\$/USD',
      description: json['description'],
      createdAt: json['createdAt'],
      createdBy: json['createdBy'],
      report: json['report'] ?? false,
    );
  }

  @override
  String toString() {
    return 'Wallet{id: $id, accountBalance: $accountBalance, name: $name, accountType: $accountType, currency: $currency, description: $description, createdAt: $createdAt, createdBy: $createdBy, report: $report, isChecked: $isChecked}';
  }
}
