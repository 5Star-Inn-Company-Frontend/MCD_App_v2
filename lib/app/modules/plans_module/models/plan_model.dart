import 'package:mcd/core/utils/amount_formatter.dart';

class PlansResponse {
  final int success;
  final String message;
  final List<PlanModel> plans;

  PlansResponse({
    required this.success,
    required this.message,
    required this.plans,
  });

  factory PlansResponse.fromJson(Map<String, dynamic> json) {
    return PlansResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      plans: (json['data'] as List?)
              ?.map((plan) => PlanModel.fromJson(plan))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': plans.map((plan) => plan.toJson()).toList(),
    };
  }
}

class PlanModel {
  final int id;
  final String name;
  final String price;
  final double userEarnAmount;
  final int userEarnPoints;
  final double referralEarnAmount;
  final int referralEarnPoints;
  final double dataBonus;
  final double airtimeBonus;
  final double tvBonus;
  final int aiChatLimit;
  final int freeSpin;
  final String createdAt;
  final String updatedAt;

  PlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.userEarnAmount,
    required this.userEarnPoints,
    required this.referralEarnAmount,
    required this.referralEarnPoints,
    required this.dataBonus,
    required this.airtimeBonus,
    required this.tvBonus,
    this.aiChatLimit = 0,
    this.freeSpin = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getter for formatted price
  String get formattedPrice {
    final priceValue = double.tryParse(price) ?? 0;
    if (priceValue == 0) return 'Free';
    return AmountUtil.formatAmountToNaira(priceValue);
  }

  // Helper getter for formatted price with proper font styling
  String get nairaSymbol => String.fromCharCode(0x20A6);
  String get priceAmount =>
      AmountUtil.formatFigure(double.tryParse(price) ?? 0);

  // Helper getter for plan description
  String get description {
    if (name.toLowerCase() == 'free') {
      return 'Get started with basic features';
    } else if (name.toLowerCase() == 'larvae') {
      return 'For individuals getting started';
    } else if (name.toLowerCase() == 'butterfly') {
      return 'For growing businesses';
    } else if (name.toLowerCase() == 'bronze') {
      return 'For small and medium businesses';
    } else if (name.toLowerCase() == 'silver') {
      return 'For established businesses';
    } else if (name.toLowerCase() == 'gold') {
      return 'For enterprise businesses';
    }
    return 'Premium subscription plan';
  }

  // Helper getter for plan features
  List<String> get features {
    final List<String> featuresList = [];

    if (dataBonus > 0) {
      featuresList.add('N${dataBonus.toStringAsFixed(0)} Data Bonus');
    }

    if (airtimeBonus > 0) {
      featuresList.add('${(airtimeBonus).toStringAsFixed(1)}% Airtime Bonus');
    }

    if (tvBonus > 0) {
      featuresList.add('${(tvBonus).toStringAsFixed(1)}% TV Bonus');
    }

    if (userEarnAmount > 0) {
      featuresList
          .add('Earn N${AmountUtil.formatFigure(userEarnAmount)} per referral');
    }

    if (userEarnPoints > 0) {
      featuresList.add('Earn $userEarnPoints points per transaction');
    }

    if (referralEarnAmount > 0) {
      featuresList.add(
          'Referral earns N${AmountUtil.formatFigure(referralEarnAmount)}');
    }

    if (referralEarnPoints > 0) {
      featuresList.add('Referral earns $referralEarnPoints points');
    }

    if (aiChatLimit > 0) {
      featuresList.add('$aiChatLimit AI Chat messages per month');
    }

    if (freeSpin > 0) {
      featuresList.add('$freeSpin Free Spins monthly');
    }

    return featuresList;
  }

  // Helper getter for badge
  String? get badge {
    if (name.toLowerCase() == 'gold') return 'POPULAR';
    if (name.toLowerCase() == 'free') return 'STARTER';
    return null;
  }

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0',
      userEarnAmount: _parseDouble(json['user_earn_amount']),
      userEarnPoints: _parseInt(json['user_earn_points']),
      referralEarnAmount: _parseDouble(json['referral_earn_amount']),
      referralEarnPoints: _parseInt(json['referral_earn_points']),
      dataBonus: _parseDouble(json['data_bonus']),
      airtimeBonus: _parseDouble(json['airtime_bonus']),
      tvBonus: _parseDouble(json['tv_bonus']),
      aiChatLimit: _parseInt(json['ai_chat_limit']),
      freeSpin: _parseInt(json['free_spin']),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'user_earn_amount': userEarnAmount,
      'user_earn_points': userEarnPoints,
      'referral_earn_amount': referralEarnAmount,
      'referral_earn_points': referralEarnPoints,
      'data_bonus': dataBonus,
      'airtime_bonus': airtimeBonus,
      'tv_bonus': tvBonus,
      'ai_chat_limit': aiChatLimit,
      'free_spin': freeSpin,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class UpgradePlanResponse {
  final int success;
  final String message;
  final dynamic data;

  UpgradePlanResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory UpgradePlanResponse.fromJson(Map<String, dynamic> json) {
    return UpgradePlanResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }
}
