class DashboardModel {
  final UserModel user;
  final BalanceModel balance;
  final VirtualAccounts virtualAccounts;
  final String news;
  final List<dynamic> specialOffers;
  final List<AppPromotionModel> appPromotions;
  final List<AppPopupModel> appPopups;

  String get cleanNews => news
      .replaceAll(r'\r\n', ' ')
      .replaceAll(r'\n', ' ')
      .replaceAll(r'\r', ' ')
      .replaceAll(r'\t', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  DashboardModel({
    required this.user,
    required this.balance,
    required this.virtualAccounts,
    required this.news,
    required this.specialOffers,
    this.appPromotions = const [],
    this.appPopups = const [],
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return DashboardModel(
      user: UserModel.fromJson(data['user']),
      balance: BalanceModel.fromJson(data['balance']),
      virtualAccounts: VirtualAccounts.fromJson(data['virtual_accounts']),
      news: data['news'] ?? "",
      specialOffers: data['special_offers'] ?? [],
      appPromotions: data['app_promotions'] != null
          ? (data['app_promotions'] as List)
              .map((e) => AppPromotionModel.fromJson(e))
              .toList()
          : [],
      appPopups: data['app_popups'] != null
          ? (data['app_popups'] as List)
              .map((e) => AppPopupModel.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "data": {
        "user": user.toJson(),
        "balance": balance.toJson(),
        "virtual_accounts": virtualAccounts.toJson(),
        "news": news,
        "special_offers": specialOffers,
        "app_promotions": appPromotions.map((e) => e.toJson()).toList(),
        "app_popups": appPopups.map((e) => e.toJson()).toList(),
      }
    };
  }

  @override
  String toString() {
    return "DashboardModel(user: $user, balance: $balance, virtualAccounts: $virtualAccounts, news: $news, specialOffers: $specialOffers)";
  }
}

class UserModel {
  final String fullName;
  final String userName;
  final String accountDetails;
  final String accountDetails2;
  final String photo;
  final String email;
  final String phoneNo;
  final String target;
  final String level;
  final String referralPlan;
  final int emailValid;
  final int phoneValid;
  final bool bvn;

  UserModel({
    required this.fullName,
    required this.userName,
    required this.accountDetails,
    required this.accountDetails2,
    required this.photo,
    required this.email,
    required this.phoneNo,
    required this.target,
    required this.level,
    required this.referralPlan,
    required this.emailValid,
    required this.phoneValid,
    required this.bvn,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['full_name'] ?? "",
      userName: json['user_name'] ?? "",
      accountDetails: json['account_details'] ?? "",
      accountDetails2: json['account_details2'] ?? "",
      photo: json['photo'] ?? "",
      email: json['email'] ?? "",
      phoneNo: json['phoneno'] ?? "",
      target: json['target'] ?? "",
      level: json['level'] ?? "",
      referralPlan: json['referral_plan'] ?? "",
      emailValid: json['email_valid'] ?? 0,
      phoneValid: json['phone_valid'] ?? 0,
      bvn: json['bvn'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "full_name": fullName,
      "user_name": userName,
      "account_details": accountDetails,
      "account_details2": accountDetails2,
      "photo": photo,
      "email": email,
      "phoneno": phoneNo,
      "target": target,
      "level": level,
      "referral_plan": referralPlan,
      "email_valid": emailValid,
      "phone_valid": phoneValid,
      "bvn": bvn,
    };
  }

  @override
  String toString() {
    return "UserModel(fullName: $fullName, userName: $userName, email: $email, phoneNo: $phoneNo, level: $level, referralPlan: $referralPlan)";
  }
}

class BalanceModel {
  final String wallet;
  final String bonus;
  final String commission;
  final String points;

  BalanceModel({
    required this.wallet,
    required this.bonus,
    required this.commission,
    required this.points,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      wallet: json['wallet'] ?? "0",
      bonus: json['bonus'] ?? "0",
      commission: json['commission'] ?? "0",
      points: json['points'] ?? "0",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "wallet": wallet,
      "bonus": bonus,
      "commission": commission,
      "points": points,
    };
  }

  @override
  String toString() {
    return "BalanceModel(wallet: $wallet, bonus: $bonus, commission: $commission, points: $points)";
  }
}

class VirtualAccounts {
  final String primaryRaw;
  final String secondaryRaw;

  VirtualAccounts({
    required this.primaryRaw,
    required this.secondaryRaw,
  });

  factory VirtualAccounts.fromJson(Map<String, dynamic> json) {
    return VirtualAccounts(
      primaryRaw: json['primary']?.toString() ?? "",
      secondaryRaw: json['secondary']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "primary": primaryRaw,
      "secondary": secondaryRaw,
    };
  }

  String get primaryAccountNumber =>
      primaryRaw.contains("|") ? primaryRaw.split("|").first.trim() : "";

  String get primaryBankName =>
      primaryRaw.contains("|") ? primaryRaw.split("|")[1].trim() : "";

  String get secondaryAccountNumber =>
      secondaryRaw.contains("|") ? secondaryRaw.split("|").first.trim() : "";

  String get secondaryBankName =>
      secondaryRaw.contains("|") ? secondaryRaw.split("|")[1].trim() : "";

  bool get hasPrimary =>
      primaryRaw.isNotEmpty && primaryRaw != "0" && primaryRaw.contains("|");

  bool get hasSecondary =>
      secondaryRaw.isNotEmpty &&
      secondaryRaw != "0" &&
      secondaryRaw.contains("|");

  @override
  String toString() {
    return "VirtualAccounts(primary: $primaryRaw, secondary: $secondaryRaw)";
  }
}

class AppPromotionModel {
  final String iconAsset;
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String subtitle1Color;
  final String buttonText;
  final String imageAsset;
  final String route;

  AppPromotionModel({
    required this.iconAsset,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.subtitle1Color,
    required this.buttonText,
    required this.imageAsset,
    required this.route,
  });

  factory AppPromotionModel.fromJson(Map<String, dynamic> json) {
    return AppPromotionModel(
      iconAsset: json['iconAsset'] ?? "",
      title: json['title'] ?? "",
      subtitle1: json['subtitle1'] ?? "",
      subtitle2: json['subtitle2'] ?? "",
      subtitle1Color: json['subtitle1Color'] ?? "#000000",
      buttonText: json['buttonText'] ?? "",
      imageAsset: json['imageAsset'] ?? "",
      route: json['route'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "iconAsset": iconAsset,
      "title": title,
      "subtitle1": subtitle1,
      "subtitle2": subtitle2,
      "subtitle1Color": subtitle1Color,
      "buttonText": buttonText,
      "imageAsset": imageAsset,
      "route": route,
    };
  }
}

class AppPopupModel {
  final String title;
  final String subtitle1;
  final String subtitle1Color;
  final String buttonText;
  final String imageAsset;
  final String route;

  AppPopupModel({
    required this.title,
    required this.subtitle1,
    required this.subtitle1Color,
    required this.buttonText,
    required this.imageAsset,
    required this.route,
  });

  factory AppPopupModel.fromJson(Map<String, dynamic> json) {
    return AppPopupModel(
      title: json['title'] ?? "",
      subtitle1: json['subtitle1'] ?? "",
      subtitle1Color: json['subtitle1Color'] ?? "#000000",
      buttonText: json['buttonText'] ?? "",
      imageAsset: json['imageAsset'] ?? "",
      route: json['route'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "subtitle1": subtitle1,
      "subtitle1Color": subtitle1Color,
      "buttonText": buttonText,
      "imageAsset": imageAsset,
      "route": route,
    };
  }
}

