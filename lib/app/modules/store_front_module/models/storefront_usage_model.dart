class StorefrontUsageModel {
  final String referralPlan;
  final int dailyOrdersUsed;
  final int dailyOrdersLimit;
  final double dailySalesUsed;
  final double dailySalesLimit;
  final double ordersPercentage;
  final double salesPercentage;
  final bool canUseVanityCode;

  StorefrontUsageModel({
    required this.referralPlan,
    required this.dailyOrdersUsed,
    required this.dailyOrdersLimit,
    required this.dailySalesUsed,
    required this.dailySalesLimit,
    required this.ordersPercentage,
    required this.salesPercentage,
    required this.canUseVanityCode,
  });

  factory StorefrontUsageModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : json);

    final data = rawData['usage'] is Map
        ? Map<String, dynamic>.from(rawData['usage'] as Map)
        : rawData;

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final plan = data['current_plan']?.toString() ??
        data['referral_plan']?.toString() ??
        data['plan']?.toString() ??
        '';
    final isVanityAllowed = plan.toLowerCase() != 'egg' &&
        plan.toLowerCase() != 'free' &&
        plan.isNotEmpty;

    return StorefrontUsageModel(
      referralPlan: plan,
      dailyOrdersUsed: parseInt(data['daily_orders_used'] ?? data['orders_used']),
      dailyOrdersLimit: parseInt(data['daily_orders_limit'] ?? data['orders_limit']),
      dailySalesUsed: parseDouble(data['daily_sales_used'] ?? data['daily_sales_volume_used']),
      dailySalesLimit: parseDouble(data['daily_sales_limit'] ?? data['daily_sales_volume_limit']),
      ordersPercentage: parseDouble(data['percentage_used'] ?? data['orders_percentage'] ?? data['orders_percent']),
      salesPercentage: parseDouble(data['percentage_used'] ?? data['sales_percentage'] ?? data['sales_percent']),
      canUseVanityCode: data['allow_custom_store_code'] is bool
          ? data['allow_custom_store_code']
          : (data['can_use_vanity_code'] is bool
              ? data['can_use_vanity_code']
              : isVanityAllowed),
    );
  }
}
