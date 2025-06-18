import 'base.dart';

class WalletModel extends Model {
  late double balance;
  late List<TransactionModel> transactions;

  WalletModel.fromJson([Map<String, dynamic>? json]) {
    balance = doubleFromJson(json, "balance");
    transactions = listFromJson(json, "wallet_transactions", callback: TransactionModel.fromJson);
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "balance": balance,
        "wallet_transactions": transactions.map((e) => e.toJson()).toList(),
      };
}

class TransactionModel extends Model {
  late final String title;
  late final DateTime date;
  late final double amount;
  TransactionModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "date");
    title = stringFromJson(json, "title");
    date = dateFromJson(json, "date");
    amount = doubleFromJson(json, "amount");
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": "تم تمويل محفظتك بنجاح",
        "date": "2025-02-04 21:20",
        "amount": 0,
      };
}
