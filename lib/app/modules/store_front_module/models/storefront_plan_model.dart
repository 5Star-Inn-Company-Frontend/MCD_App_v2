class StorefrontPlanModel {
  final String itemCode;
  final String name;
  final double baseCost;
  final double sellPrice;
  final double maxAllowedPrice;
  final double commission;
  final bool isEnabled;
  final bool needsPriceUpdate;

  StorefrontPlanModel({
    required this.itemCode,
    required this.name,
    required this.baseCost,
    required this.sellPrice,
    required this.maxAllowedPrice,
    required this.commission,
    required this.isEnabled,
    required this.needsPriceUpdate,
  });

  factory StorefrontPlanModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic val, [bool fallback = true]) {
      if (val == null) return fallback;
      if (val is bool) return val;
      if (val is num) return val == 1;
      final str = val.toString().toLowerCase().trim();
      return str == '1' || str == 'true';
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final base = parseDouble(json['base_cost'] ?? json['cost']);
    final sell = parseDouble(json['sell_price'] ?? json['price']);
    final maxAllowed = parseDouble(json['max_allowed_price'] ?? (base > 0 ? base * 1.2 : sell));
    final comm = parseDouble(json['commission'] ?? (sell - base > 0 ? sell - base : 0.0));

    return StorefrontPlanModel(
      itemCode: json['item_code']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['plan_name']?.toString() ?? json['item_code']?.toString() ?? '',
      baseCost: base,
      sellPrice: sell,
      maxAllowedPrice: maxAllowed,
      commission: comm,
      isEnabled: parseBool(json['is_enabled'] ?? json['status'], true),
      needsPriceUpdate: parseBool(json['needs_price_update'], false),
    );
  }

  StorefrontPlanModel copyWith({
    String? itemCode,
    String? name,
    double? baseCost,
    double? sellPrice,
    double? maxAllowedPrice,
    double? commission,
    bool? isEnabled,
    bool? needsPriceUpdate,
  }) {
    return StorefrontPlanModel(
      itemCode: itemCode ?? this.itemCode,
      name: name ?? this.name,
      baseCost: baseCost ?? this.baseCost,
      sellPrice: sellPrice ?? this.sellPrice,
      maxAllowedPrice: maxAllowedPrice ?? this.maxAllowedPrice,
      commission: commission ?? this.commission,
      isEnabled: isEnabled ?? this.isEnabled,
      needsPriceUpdate: needsPriceUpdate ?? this.needsPriceUpdate,
    );
  }
}
