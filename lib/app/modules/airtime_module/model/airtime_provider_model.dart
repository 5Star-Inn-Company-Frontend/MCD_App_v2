class AirtimeProvider {
  final String network;
  final String discount;
  final int status;
  final String server;
  final double? minAmount;
  final double? maxAmount;

  AirtimeProvider({
    required this.network,
    required this.discount,
    required this.status,
    required this.server,
    this.minAmount,
    this.maxAmount,
  });

  factory AirtimeProvider.fromJson(Map<String, dynamic> json) {
    return AirtimeProvider(
      network: json['network'] ?? json['name'] ?? '',
      discount: json['discount']?.toString() ?? json['commission']?.toString() ?? '0',
      status: _parseInt(json['status'] ?? 1),
      server: json['server']?.toString() ?? json['operatorId']?.toString() ?? '',
      minAmount: _parseDouble(json['minAmount'] ?? json['min_amount']),
      maxAmount: _parseDouble(json['maxAmount'] ?? json['max_amount']),
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