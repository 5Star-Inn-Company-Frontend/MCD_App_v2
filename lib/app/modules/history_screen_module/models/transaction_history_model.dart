class TransactionHistoryModel {
  final int success;
  final String message;
  final TransactionDataPagination data;

  TransactionHistoryModel({
    required this.success,
    required this.message,
    required this.data,
  });

  // For backward compatibility
  List<Transaction> get transactions => data.transactions;
  double get totalIn => 0.0;
  double get totalOut => 0.0;

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: TransactionDataPagination.fromJson(json['data'] ?? {}),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class TransactionDataPagination {
  final int currentPage;
  final List<Transaction> transactions;
  final String? firstPageUrl;
  final int from;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;

  TransactionDataPagination({
    required this.currentPage,
    required this.transactions,
    this.firstPageUrl,
    required this.from,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
  });

  factory TransactionDataPagination.fromJson(Map<String, dynamic> json) {
    return TransactionDataPagination(
      currentPage: json['current_page'] ?? 1,
      transactions: (json['data'] as List?)
              ?.map((transaction) => Transaction.fromJson(transaction))
              .toList() ??
          [],
      firstPageUrl: json['first_page_url'],
      from: json['from'] ?? 0,
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': transactions.map((t) => t.toJson()).toList(),
      'first_page_url': firstPageUrl,
      'from': from,
      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'prev_page_url': prevPageUrl,
      'to': to,
    };
  }
}

class Transaction {
  final int id;
  final String ref;
  final String name;
  final dynamic amount;
  final String status;
  final String description;
  final String date;
  final String userName;
  final String ipAddress;
  final String code;
  final String? iWallet;
  final String? fWallet;
  final String? token;
  final ServerLog? serverLog;

  Transaction({
    required this.id,
    required this.ref,
    required this.name,
    required this.amount,
    required this.status,
    required this.description,
    required this.date,
    required this.userName,
    required this.ipAddress,
    required this.code,
    this.iWallet,
    this.fWallet,
    this.token,
    this.serverLog,
  });

  // Get amount as double
  double get amountValue {
    if (amount is double) return amount;
    if (amount is int) return amount.toDouble();
    if (amount is String) return double.tryParse(amount.toString()) ?? 0.0;
    return 0.0;
  }

  // Check if transaction is credit (money in)
  bool get isCredit {
    final codeLower = code.toLowerCase();
    final nameLower = name.toLowerCase();

    return codeLower.contains('commission') ||
        codeLower.contains('tcommission') ||
        codeLower.contains('reversal') ||
        codeLower.contains('credit') ||
        codeLower.contains('received') ||
        nameLower.contains('commission') ||
        nameLower.contains('reversal');
  }

  // Get formatted date and time
  String get formattedTime {
    try {
      final dateTime = DateTime.parse(date);
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final period = dateTime.hour >= 12 ? 'pm' : 'am';
      final year = dateTime.year.toString();
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      return '$year-$month-$day • ${hour == 0 ? 12 : hour}:${dateTime.minute.toString().padLeft(2, '0')}$period';
    } catch (e) {
      return date;
    }
  }

  // Get phone number from server_log or description
  String get phoneNumber {
    // First check server_log
    if (serverLog != null && serverLog!.phone.isNotEmpty) {
      return serverLog!.phone;
    }

    // Try to extract from description
    final phoneRegex = RegExp(r'\b(0\d{10}|\+?\d{11,13})\b');
    final match = phoneRegex.firstMatch(description);
    if (match != null) {
      return match.group(0) ?? 'N/A';
    }

    return 'N/A';
  }

  // Get network/service provider
  String get networkProvider {
    if (serverLog != null && serverLog!.network.isNotEmpty) {
      return serverLog!.network;
    }

    // Fallback: Try to find network in description
    final desc = description.toLowerCase();
    if (desc.contains('mtn')) return 'MTN';
    if (desc.contains('glo')) return 'Glo';
    if (desc.contains('airtel')) return 'Airtel';
    if (desc.contains('9mobile') || desc.contains('etisalat')) return '9mobile';
    if (desc.contains('spectranet')) return 'Spectranet';
    if (desc.contains('smile')) return 'Smile';

    // If name is generic like 'data' or 'airtime', don't return it as network
    if (name.toLowerCase() == 'data' ||
        name.toLowerCase() == 'airtime' ||
        name.toLowerCase() == 'wallet_funding') {
      return '';
    }

    return name;
  }

  // Get transaction type for display
  String get type => name;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      ref: json['ref'] ?? '',
      name: json['name'] ?? '',
      amount: json['amount'] ?? 0,
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      userName: json['user_name'] ?? '',
      ipAddress: json['ip_address'] ?? '',
      code: json['code'] ?? '',
      iWallet: json['i_wallet']?.toString(),
      fWallet: json['f_wallet']?.toString(),
      token: json['token'],
      serverLog: (json['server_log'] != null && json['server_log'] is Map)
          ? ServerLog.fromJson(json['server_log'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ref': ref,
      'name': name,
      'amount': amount,
      'status': status,
      'description': description,
      'date': date,
      'user_name': userName,
      'ip_address': ipAddress,
      'code': code,
      'i_wallet': iWallet,
      'f_wallet': fWallet,
      'token': token,
      'server_log': serverLog?.toJson(),
    };
  }
}

class ServerLog {
  final int id;
  final String service;
  final String amount;
  final String phone;
  final String network;
  final String date;
  final String userName;
  final String transid;
  final String ident;
  final String status;
  final String ipAddress;
  final String? deviceDetails;
  final String? coded;
  final String paymentMethod;
  final String quantity;
  final String? designType;
  final String wallet;
  final String country;
  final String? api;
  final String? version;
  final String createdAt;
  final String updatedAt;

  ServerLog({
    required this.id,
    required this.service,
    required this.amount,
    required this.phone,
    required this.network,
    required this.date,
    required this.userName,
    required this.transid,
    required this.ident,
    required this.status,
    required this.ipAddress,
    this.deviceDetails,
    this.coded,
    required this.paymentMethod,
    required this.quantity,
    this.designType,
    required this.wallet,
    required this.country,
    this.api,
    this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServerLog.fromJson(Map<String, dynamic> json) {
    return ServerLog(
      id: json['id'] ?? 0,
      service: json['service'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      phone: json['phone'] ?? '',
      network: json['network'] ?? '',
      date: json['date'] ?? '',
      userName: json['user_name'] ?? '',
      transid: json['transid'] ?? '',
      ident: json['ident'] ?? '',
      status: json['status'] ?? '',
      ipAddress: json['ip_address'] ?? '',
      deviceDetails: json['device_details'],
      coded: json['coded'],
      paymentMethod: json['payment_method'] ?? '',
      quantity: json['quantity']?.toString() ?? '1',
      designType: json['design_type'],
      wallet: json['wallet']?.toString() ?? '0',
      country: json['country'] ?? '',
      api: json['api'],
      version: json['version'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service,
      'amount': amount,
      'phone': phone,
      'network': network,
      'date': date,
      'user_name': userName,
      'transid': transid,
      'ident': ident,
      'status': status,
      'ip_address': ipAddress,
      'device_details': deviceDetails,
      'coded': coded,
      'payment_method': paymentMethod,
      'quantity': quantity,
      'wallet': wallet,
      'country': country,
      'api': api,
      'version': version,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
