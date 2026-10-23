class StorefrontProviderModel {
  final String provider;
  final bool isEnabled;
  final double discountPercent;
  final double baseDiscount;
  final List<String> types;

  StorefrontProviderModel({
    required this.provider,
    required this.isEnabled,
    required this.discountPercent,
    required this.baseDiscount,
    this.types = const [],
  });

  factory StorefrontProviderModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic val, [bool fallback = true]) {
      if (val == null) return fallback;
      if (val is bool) return val;
      if (val is num) return val == 1;
      final str = val.toString().toLowerCase().trim();
      return str == '1' || str == 'true' || str == 'active';
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    List<String> parseTypes(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return const [];
    }

    final providerName = json['provider']?.toString() ??
        json['network']?.toString() ??
        json['code']?.toString() ??
        json['name']?.toString() ??
        json['service']?.toString() ??
        json['service_id']?.toString() ??
        '';

    return StorefrontProviderModel(
      provider: providerName,
      isEnabled: parseBool(
        json['is_enabled'] ?? json['system_active'] ?? json['status'] ?? json['enabled'] ?? json['active'],
        true,
      ),
      discountPercent: parseDouble(
        json['agent_discount_percent'] ??
            json['discount_percent'] ??
            json['discount'] ??
            json['markup_percent'] ??
            json['markup'] ??
            json['margin'] ??
            0.0,
      ),
      baseDiscount: parseDouble(
        json['base_discount_percent'] ??
            json['base_discount'] ??
            json['mcd_base_discount'] ??
            json['base_margin'] ??
            json['mcd_discount'] ??
            0.0,
      ),
      types: parseTypes(json['types'] ?? json['data_types'] ?? json['bundles']),
    );
  }

  StorefrontProviderModel copyWith({
    String? provider,
    bool? isEnabled,
    double? discountPercent,
    double? baseDiscount,
    List<String>? types,
  }) {
    return StorefrontProviderModel(
      provider: provider ?? this.provider,
      isEnabled: isEnabled ?? this.isEnabled,
      discountPercent: discountPercent ?? this.discountPercent,
      baseDiscount: baseDiscount ?? this.baseDiscount,
      types: types ?? this.types,
    );
  }
}
