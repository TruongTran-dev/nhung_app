import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final int id;
  final int accountBalance;
  final String name;
  final String accountType;
  final String currency;
  final String? description;
  final String? createdAt;
  final int? createdBy;
  final bool report;

  final bool isChecked;

  const Wallet({
    required this.id,
    required this.accountBalance,
    required this.name,
    required this.accountType,
    required this.currency,
    this.description,
    this.createdAt,
    this.createdBy,
    this.report = false,
    this.isChecked = false,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] != null
          ? json['id'] is int
              ? json['id']
              : (json['id'] as num).toInt()
          : null,
      accountBalance: json['accountBalance'] != null
          ? json['accountBalance'] is int
              ? json['accountBalance']
              : (json['accountBalance'] as num).toInt()
          : 0,
      name: json['name'],
      accountType: json['accountType'],
      currency: json['currency'] ?? '\$/VND',
      description: json['description'],
      createdAt: json['createdAt'],
      createdBy: json['createdBy'],
      report: json['report'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        accountBalance,
        name,
        accountType,
        currency,
        description,
        createdAt,
        createdBy,
        report,
        isChecked,
      ];

  @override
  bool get stringify => true;

  Wallet copyWith({
    int? id,
    int? accountBalance,
    String? name,
    String? accountType,
    String? currency,
    String? description,
    String? createdAt,
    int? createdBy,
    bool? report,
    bool? isChecked,
  }) {
    return Wallet(
      id: id ?? this.id,
      accountBalance: accountBalance ?? this.accountBalance,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      report: report ?? this.report,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  @override
  String toString() {
    return 'Wallet{id: $id, accountBalance: $accountBalance, name: $name, accountType: $accountType, currency: $currency, description: $description, createdAt: $createdAt, createdBy: $createdBy, report: $report, isChecked: $isChecked}';
  }
}
