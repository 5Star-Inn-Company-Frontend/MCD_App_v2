class AirtimeProvider {
  final String network;
  final String discount;
  final int status;
  final String server;
  final double? minAmount;
  final double? maxAmount;
  final String? coded;
  final double? conversionRate;
  final String? localCurrency;
  final double? localMinAmount;
  final double? localMaxAmount;
  final String? operatorId;
  final String? countryCode;

  AirtimeProvider({
    required this.network,
    required this.discount,
    required this.status,
    required this.server,
    this.minAmount,
    this.maxAmount,
    this.coded,
    this.conversionRate,
    this.localCurrency,
    this.localMinAmount,
    this.localMaxAmount,
    this.operatorId,
    this.countryCode,
  });

  factory AirtimeProvider.fromJson(Map<String, dynamic> json) {
    String? varCoded;
    final variations = json['variations'];
    if (variations is List && variations.isNotEmpty) {
      final firstVar = variations.first;
      if (firstVar is Map) {
        varCoded = firstVar['coded']?.toString() ??
            firstVar['variation_code']?.toString();
      }
    }

    return AirtimeProvider(
      network: json['network'] ?? json['name'] ?? '',
      discount: json['discount']?.toString() ??
          json['commission']?.toString() ??
          '0',
      status: _parseInt(json['status'] ?? 1),
      server: json['server']?.toString() ??
          json['operatorId']?.toString() ??
          json['operator_id']?.toString() ??
          '',
      minAmount: _parseDouble(json['minAmount'] ?? json['min_amount']),
      maxAmount: _parseDouble(json['maxAmount'] ?? json['max_amount']),
      coded: json['coded']?.toString() ?? varCoded,
      conversionRate: _parseDouble(json['conversion_rate'] ?? json['rate']),
      localCurrency: json['local_currency']?.toString(),
      localMinAmount: _parseDouble(json['local_min_amount']),
      localMaxAmount: _parseDouble(json['local_max_amount']),
      operatorId: json['operator_id']?.toString() ??
          json['operatorId']?.toString(),
      countryCode: json['country_code']?.toString() ??
          json['countryCode']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}