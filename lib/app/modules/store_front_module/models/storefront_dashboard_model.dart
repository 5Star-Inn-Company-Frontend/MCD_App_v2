class StorefrontDashboardModel {
  final String storeName;
  final String welcomeMessage;
  final bool status;
  final String storeCode;
  final String whatsappLink;
  final num todaySales;
  final int customersCount;
  final num todayCommission;
  final bool acceptCard;
  final bool acceptVirtualAccount;
  final bool acceptMobileMoney;

  StorefrontDashboardModel({
    required this.storeName,
    required this.welcomeMessage,
    required this.status,
    required this.storeCode,
    required this.whatsappLink,
    required this.todaySales,
    required this.customersCount,
    required this.todayCommission,
    required this.acceptCard,
    required this.acceptVirtualAccount,
    required this.acceptMobileMoney,
  });

  factory StorefrontDashboardModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : json);

    final store = rawData['store'] is Map
        ? Map<String, dynamic>.from(rawData['store'] as Map)
        : rawData;

    final metrics = rawData['metrics'] is Map
        ? Map<String, dynamic>.from(rawData['metrics'] as Map)
        : rawData;

    final paymentMethods = store['payment_methods'] is Map
        ? Map<String, dynamic>.from(store['payment_methods'] as Map)
        : (rawData['payment_methods'] is Map
            ? Map<String, dynamic>.from(rawData['payment_methods'] as Map)
            : rawData);

    bool parseBool(dynamic val, [bool fallback = false]) {
      if (val == null) return fallback;
      if (val is bool) return val;
      if (val is num) return val == 1;
      final str = val.toString().toLowerCase().trim();
      return str == '1' || str == 'true' || str == 'active';
    }

    num parseNum(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val;
      return num.tryParse(val.toString()) ?? 0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return StorefrontDashboardModel(
      storeName: store['store_name']?.toString() ?? rawData['store_name']?.toString() ?? '',
      welcomeMessage: store['welcome_message']?.toString() ?? rawData['welcome_message']?.toString() ?? '',
      status: parseBool(store['status'] ?? rawData['status'], true),
      storeCode: store['store_code']?.toString() ?? rawData['store_code']?.toString() ?? '',
      whatsappLink: store['whatsapp_link']?.toString() ??
          store['deep_link']?.toString() ??
          rawData['whatsapp_link']?.toString() ??
          rawData['deep_link']?.toString() ??
          '',
      todaySales: parseNum(metrics['today_sales'] ?? rawData['today_sales']),
      customersCount: parseInt(
        metrics['customers_count'] ??
            metrics['customers'] ??
            rawData['customers_count'],
      ),
      todayCommission: parseNum(
        metrics['today_commission'] ??
            metrics['commission'] ??
            rawData['today_commission'],
      ),
      acceptCard: parseBool(paymentMethods['accept_card'], false),
      acceptVirtualAccount: parseBool(paymentMethods['accept_virtual_account'], true),
      acceptMobileMoney: parseBool(paymentMethods['accept_mobile_money'], false),
    );
  }

  StorefrontDashboardModel copyWith({
    String? storeName,
    String? welcomeMessage,
    bool? status,
    String? storeCode,
    String? whatsappLink,
    num? todaySales,
    int? customersCount,
    num? todayCommission,
    bool? acceptCard,
    bool? acceptVirtualAccount,
    bool? acceptMobileMoney,
  }) {
    return StorefrontDashboardModel(
      storeName: storeName ?? this.storeName,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      status: status ?? this.status,
      storeCode: storeCode ?? this.storeCode,
      whatsappLink: whatsappLink ?? this.whatsappLink,
      todaySales: todaySales ?? this.todaySales,
      customersCount: customersCount ?? this.customersCount,
      todayCommission: todayCommission ?? this.todayCommission,
      acceptCard: acceptCard ?? this.acceptCard,
      acceptVirtualAccount: acceptVirtualAccount ?? this.acceptVirtualAccount,
      acceptMobileMoney: acceptMobileMoney ?? this.acceptMobileMoney,
    );
  }
}
