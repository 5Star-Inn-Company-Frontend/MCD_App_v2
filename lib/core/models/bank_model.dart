class BankModel {
  final int id;
  final String name;
  final String code;
  final String slug;
  final bool active;
  final String country;
  final String currency;
  final String? ussdTemplate;
  final String? baseUssdCode;

  BankModel({
    required this.id,
    required this.name,
    required this.code,
    required this.slug,
    required this.active,
    required this.country,
    required this.currency,
    this.ussdTemplate,
    this.baseUssdCode,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      slug: json['slug'] ?? '',
      active: json['active'] ?? false,
      country: json['country'] ?? '',
      currency: json['currency'] ?? '',
      ussdTemplate: json['ussdTemplate'],
      baseUssdCode: json['baseUssdCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'slug': slug,
      'active': active,
      'country': country,
      'currency': currency,
      'ussdTemplate': ussdTemplate,
      'baseUssdCode': baseUssdCode,
    };
  }
}
