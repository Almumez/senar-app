import 'base.dart';

class WalletModel {
  final double balance;
  final List<TransactionModel> transactions;

  WalletModel({
    required this.balance,
    required this.transactions,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        balance: double.tryParse(json["balance"].toString()) ?? 0.0,
        transactions: List<TransactionModel>.from(json["transactions"].map((x) => TransactionModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "balance": balance,
        "transactions": List<dynamic>.from(transactions.map((x) => x.toJson())),
      };
}

class TransactionModel {
  final String id;
  final String amount;
  final String type;
  final String date;
  final String? note;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json["id"].toString(),
        amount: json["amount"].toString(),
        type: json["type"].toString(),
        date: json["date"].toString(),
        note: json["note"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "type": type,
        "date": date,
        "note": note,
      };
}

class WithdrawalRequestModel {
  final String requestNumber;
  final String amount;
  final String approvedAmount;
  final String status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? note;
  final FreeAgentModel freeAgent;

  WithdrawalRequestModel({
    required this.requestNumber,
    required this.amount,
    required this.approvedAmount,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.note,
    required this.freeAgent,
  });

  factory WithdrawalRequestModel.fromJson(Map<String, dynamic> json) => WithdrawalRequestModel(
    requestNumber: json["request_number"],
    amount: json["amount"],
    approvedAmount: json["approved_amount"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    processedAt: json["processed_at"] != null ? DateTime.parse(json["processed_at"]) : null,
    note: json["note"],
    freeAgent: FreeAgentModel.fromJson(json["freeAgent"]),
  );

  Map<String, dynamic> toJson() => {
    "request_number": requestNumber,
    "amount": amount,
    "approved_amount": approvedAmount,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "processed_at": processedAt?.toIso8601String(),
    "note": note,
    "freeAgent": freeAgent.toJson(),
  };

  String get formattedCreatedAt {
    return "${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}";
  }

  String get formattedProcessedAt {
    if (processedAt == null) return '';
    return "${processedAt!.year}-${processedAt!.month.toString().padLeft(2, '0')}-${processedAt!.day.toString().padLeft(2, '0')}";
  }
}

class FreeAgentModel {
  final int id;
  final String? name;

  FreeAgentModel({
    required this.id,
    this.name,
  });

  factory FreeAgentModel.fromJson(Map<String, dynamic> json) => FreeAgentModel(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
