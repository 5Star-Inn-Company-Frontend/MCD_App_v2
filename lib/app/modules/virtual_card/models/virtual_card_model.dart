import 'dart:convert';

class VirtualCardModel {
  final int id;
  final String userName;
  final String cardId;
  final String cardType;
  final String customerId;
  final String brand;
  final String name;
  final String cardNumber;
  final String masked;
  final String expiryDate;
  final String cvv;
  final String currency;
  final int status;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  VirtualCardModel({
    required this.id,
    required this.userName,
    required this.cardId,
    required this.cardType,
    required this.customerId,
    required this.brand,
    required this.name,
    required this.cardNumber,
    required this.masked,
    required this.expiryDate,
    required this.cvv,
    required this.currency,
    required this.address,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VirtualCardModel.fromJson(Map<String, dynamic> json) {
    return VirtualCardModel(
      id: json['id'] ?? 0,
      userName: json['user_name']?.toString() ?? '',
      cardId: json['card_id']?.toString() ?? '',
      cardType: json['card_type']?.toString() ?? 'virtual',
      customerId: json['customer_id']?.toString() ?? '',
      brand: json['brand']?.toString() ?? 'mastercard',
      name: json['name']?.toString() ?? '',
      cardNumber: json['number']?.toString() ?? '',
      masked: json['masked']?.toString() ?? '',
      expiryDate: json['expiry']?.toString() ?? '',
      cvv: json['ccv']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'USD',
      status: json['status'] ?? 1,
      address: json['address'] is Map
          ? jsonEncode(json['address'])
          : json['address']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'card_id': cardId,
      'card_type': cardType,
      'customer_id': customerId,
      'brand': brand,
      'name': name,
      'number': cardNumber,
      'masked': masked,
      'expiry': expiryDate,
      'ccv': cvv,
      'currency': currency,
      'status': status,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get statusString => status == 1 ? 'active' : 'inactive';
}

class VirtualCardListResponse {
  final int success;
  final String message;
  final double createFee;
  final double rate;
  final List<VirtualCardModel> data;

  VirtualCardListResponse({
    required this.success,
    required this.message,
    required this.createFee,
    required this.rate,
    required this.data,
  });

  factory VirtualCardListResponse.fromJson(Map<String, dynamic> json) {
    List<VirtualCardModel> cardList = [];
    if (json['data'] != null) {
      if (json['data'] is List) {
        cardList = (json['data'] as List)
            .map((card) => VirtualCardModel.fromJson(card))
            .toList();
      }
    }

    return VirtualCardListResponse(
      success: json['success'] ?? 0,
      message: json['message']?.toString() ?? '',
      createFee: double.tryParse(json['create_fee']?.toString() ?? '0') ?? 0.0,
      rate: double.tryParse(json['rate']?.toString() ?? '0') ?? 0.0,
      data: cardList,
    );
  }
}
