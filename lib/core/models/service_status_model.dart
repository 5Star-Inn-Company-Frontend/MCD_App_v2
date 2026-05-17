class ServiceStatusModel {
  final int success;
  final String message;
  final ServiceStatusData? data;

  ServiceStatusModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ServiceStatusModel.fromJson(Map<String, dynamic> json) {
    return ServiceStatusModel(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? ServiceStatusData.fromJson(json['data']) : null,
    );
  }
}

class ServiceStatusData {
  final Services services;
  final Adverts? adverts;
  final Others? others;
  final List<dynamic> specialOffers;
  // raw services map for action button filtering
  final Map<String, dynamic> rawServices;

  ServiceStatusData({
    required this.services,
    this.adverts,
    this.others,
    this.specialOffers = const [],
    this.rawServices = const {},
  });

  factory ServiceStatusData.fromJson(Map<String, dynamic> json) {
    return ServiceStatusData(
      services: Services.fromJson(json['services'] ?? {}),
      adverts: json['adverts'] != null ? Adverts.fromJson(json['adverts']) : null,
      others: json['others'] != null ? Others.fromJson(json['others']) : null,
      specialOffers: json['special_offers'] ?? [],
      rawServices: (json['services'] as Map<String, dynamic>?) ?? {},
    );
  }
}

class Services {
  final String airtime;
  final String data;
  final String paytv;
  final String resultchecker;
  final String rechargecard;
  final String electricity;
  final String betting;
  final String airtimeconverter;
  final String foreignAirtime;
  final String jamb;
  final String ninValidation;
  final String bizVerification;
  final String findBvn;
  final String bvnVerification;
  final String megaland;
  final String foreignData;
  final String dataPin;
  final String airtimePin;
  final String spinwin;
  final String giveaway;
  final String predictwin;
  final String freemoney;
  final String freeMoneyAmount;
  final String virtualCard;

  Services({
    required this.airtime,
    required this.data,
    required this.paytv,
    required this.resultchecker,
    required this.rechargecard,
    required this.electricity,
    required this.betting,
    required this.airtimeconverter,
    required this.foreignAirtime,
    required this.jamb,
    required this.ninValidation,
    required this.bizVerification,
    required this.findBvn,
    required this.bvnVerification,
    required this.megaland,
    required this.foreignData,
    required this.dataPin,
    required this.airtimePin,
    required this.spinwin,
    required this.giveaway,
    required this.predictwin,
    required this.freemoney,
    required this.freeMoneyAmount,
    required this.virtualCard,
  });

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      airtime: json['airtime']?.toString() ?? '0',
      data: json['data']?.toString() ?? '0',
      paytv: json['paytv']?.toString() ?? '0',
      resultchecker: json['resultchecker']?.toString() ?? '0',
      rechargecard: json['rechargecard']?.toString() ?? '0',
      electricity: json['electricity']?.toString() ?? '0',
      betting: json['betting']?.toString() ?? '0',
      airtimeconverter: json['airtimeconverter']?.toString() ?? '0',
      foreignAirtime: json['foreign_airtime']?.toString() ?? '0',
      jamb: json['jamb']?.toString() ?? '0',
      ninValidation: json['nin_validation']?.toString() ?? '0',
      bizVerification: json['biz_verification']?.toString() ?? '0',
      findBvn: json['find_bvn']?.toString() ?? '0',
      bvnVerification: json['bvn_verification']?.toString() ?? '0',
      megaland: json['megaland']?.toString() ?? '0',
      foreignData: json['foreign_data']?.toString() ?? '0',
      dataPin: json['data_pin']?.toString() ?? '0',
      airtimePin: json['airtime_pin']?.toString() ?? '0',
      spinwin: json['spinwin']?.toString() ?? '0',
      giveaway: json['giveaway']?.toString() ?? '0',
      predictwin: json['predictwin']?.toString() ?? '0',
      freemoney: json['freemoney']?.toString() ?? '0',
      freeMoneyAmount: json['free_money_amount']?.toString() ?? '0',
      virtualCard: json['virtual_card']?.toString() ?? '0',
    );
  }

  bool isServiceAvailable(String serviceKey) {
    switch (serviceKey.toLowerCase()) {
      case 'airtime':
        return airtime == '1';
      case 'data':
        return data == '1';
      case 'paytv':
      case 'cable':
        return paytv == '1';
      case 'resultchecker':
        return resultchecker == '1';
      case 'rechargecard':
      case 'epin':
        return rechargecard == '1';
      case 'electricity':
        return electricity == '1';
      case 'betting':
        return betting == '1';
      case 'airtimeconverter':
        return airtimeconverter == '1';
      case 'foreign_airtime':
        return foreignAirtime == '1';
      case 'jamb':
        return jamb == '1';
      case 'nin_validation':
        return ninValidation == '1';
      case 'biz_verification':
        return bizVerification == '1';
      case 'find_bvn':
        return findBvn == '1';
      case 'bvn_verification':
        return bvnVerification == '1';
      case 'megaland':
        return megaland == '1';
      case 'foreign_data':
        return foreignData == '1';
      case 'data_pin':
        return dataPin == '1';
      case 'airtime_pin':
        return airtimePin == '1';
      case 'spinwin':
        return spinwin == '1';
      case 'giveaway':
        return giveaway == '1';
      case 'predictwin':
        return predictwin == '1';
      case 'freemoney':
        return freemoney == '1';
      case 'virtual_card':
        return virtualCard == '1';
      default:
        return false;
    }
  }
}

class Adverts {
  final String unityTestmode;
  final String unityGameid;

  Adverts({
    required this.unityTestmode,
    required this.unityGameid,
  });

  factory Adverts.fromJson(Map<String, dynamic> json) {
    return Adverts(
      unityTestmode: json['unity_testmode']?.toString() ?? 'false',
      unityGameid: json['unity_gameid']?.toString() ?? '',
    );
  }
}

class Others {
  final String mcdAgentPhoneno;
  final String leaderboardBanner;
  final String leaderboard;
  final String supportEmail;
  final String gnewsAction;
  final String resellerSamples;
  final List<String> imageSliders;

  Others({
    required this.mcdAgentPhoneno,
    required this.leaderboardBanner,
    required this.leaderboard,
    required this.supportEmail,
    required this.gnewsAction,
    required this.resellerSamples,
    this.imageSliders = const [],
  });

  factory Others.fromJson(Map<String, dynamic> json) {
    return Others(
      mcdAgentPhoneno: json['mcd_agent_phoneno']?.toString() ?? '',
      leaderboardBanner: json['leaderboard_banner']?.toString() ?? '',
      leaderboard: json['leaderboard']?.toString() ?? '0',
      supportEmail: json['support_email']?.toString() ?? '',
      gnewsAction: json['gnews_action']?.toString() ?? '',
      resellerSamples: json['reseller_samples']?.toString() ?? '',
      imageSliders: json['image_sliders'] != null
          ? List<String>.from(json['image_sliders'])
          : [],
    );
  }
}
