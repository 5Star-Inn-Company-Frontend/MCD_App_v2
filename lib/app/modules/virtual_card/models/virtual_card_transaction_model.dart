class VirtualCardTransactionModel {
  final int id;
  final String transId;
  final String type;
  final String description;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;

  VirtualCardTransactionModel({
    required this.id,
    required this.transId,
    required this.type,
    required this.description,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  factory VirtualCardTransactionModel.fromJson(Map<String, dynamic> json) {
    final transId = json['trans_id']?.toString() ?? '';
    final desc = json['description']?.toString() ?? '';

    // derive credit/debit from description since api has no type field
    final type = desc.toLowerCase().contains('topup') ? 'credit' : 'debit';

    return VirtualCardTransactionModel(
      id: transId.hashCode,
      transId: transId,
      type: type,
      description: desc,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class VirtualCardTransactionListResponse {
  final int success;
  final String message;
  final List<VirtualCardTransactionModel> transactions;
  final int total;

  VirtualCardTransactionListResponse({
    required this.success,
    required this.message,
    required this.transactions,
    required this.total,
  });

  factory VirtualCardTransactionListResponse.fromJson(
      Map<String, dynamic> json) {
    List<VirtualCardTransactionModel> transactionList = [];

    // api wraps list under data.transactions, not data directly
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final list = data['transactions'];
      if (list is List) {
        transactionList = list
            .map((t) =>
                VirtualCardTransactionModel.fromJson(t as Map<String, dynamic>))
            .toList();
      }
    } else if (data is List) {
      // fallback in case api changes
      transactionList = data
          .map((t) =>
              VirtualCardTransactionModel.fromJson(t as Map<String, dynamic>))
          .toList();
    }

    return VirtualCardTransactionListResponse(
      success: json['success'] ?? 0,
      message: json['message']?.toString() ?? '',
      transactions: transactionList,
      total: (json['data'] is Map) ? (json['data']['total'] ?? 0) : 0,
    );
  }
}
