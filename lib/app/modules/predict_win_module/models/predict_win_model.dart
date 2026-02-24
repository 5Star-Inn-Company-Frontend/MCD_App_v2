// Reward model for horizontal spinning wheel
class PredictWinReward {
  final int id;
  final String name;
  final int qty;
  final String type;
  final String network;
  final int amount;
  final String coded;

  PredictWinReward({
    required this.id,
    required this.name,
    required this.qty,
    required this.type,
    required this.network,
    required this.amount,
    required this.coded,
  });

  factory PredictWinReward.fromJson(Map<String, dynamic> json) {
    return PredictWinReward(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      qty: json['qty'] is int ? json['qty'] : int.tryParse(json['qty'].toString()) ?? 0,
      type: json['type']?.toString() ?? '',
      network: json['network']?.toString() ?? '',
      amount: json['amount'] is int ? json['amount'] : int.tryParse(json['amount'].toString()) ?? 0,
      coded: json['coded']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'qty': qty,
      'type': type,
      'network': network,
      'amount': amount,
      'coded': coded,
    };
  }

  String get displayName {
    if (type == 'airtime') {
      return '₦$amount $network Airtime';
    } else if (type == 'data') {
      return '$name - $network';
    } else if (type == 'betting') {
      return '₦$amount $network Credit';
    }
    return name;
  }
}

// Question model
class PredictWinQuestion {
  final int id;
  final String image;
  final String question;
  final String answer;
  final int status;
  final String endAt;
  final String? resultAt;

  PredictWinQuestion({
    required this.id,
    required this.image,
    required this.question,
    required this.answer,
    required this.status,
    required this.endAt,
    this.resultAt,
  });

  factory PredictWinQuestion.fromJson(Map<String, dynamic> json) {
    return PredictWinQuestion(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      image: json['image']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : int.tryParse(json['status'].toString()) ?? 0,
      endAt: json['end_at']?.toString() ?? '',
      resultAt: json['result_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'question': question,
      'answer': answer,
      'status': status,
      'end_at': endAt,
      'result_at': resultAt,
    };
  }

  bool get isActive => status == 1;
}

// Main prediction model
class PredictWinModel {
  final PredictWinQuestion question;
  final List<PredictWinReward> rewards;

  PredictWinModel({
    required this.question,
    required this.rewards,
  });

  factory PredictWinModel.fromJson(Map<String, dynamic> json) {
    return PredictWinModel(
      question: PredictWinQuestion.fromJson(json['ques'] ?? {}),
      rewards: (json['data'] as List<dynamic>?)
              ?.map((reward) =>
                  PredictWinReward.fromJson(reward as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ques': question.toJson(),
      'data': rewards.map((r) => r.toJson()).toList(),
    };
  }

  bool get isActive => question.isActive;
}

class PredictWinResponse {
  final int success;
  final String message;
  final PredictWinModel? data;

  PredictWinResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory PredictWinResponse.fromJson(Map<String, dynamic> json) {
    PredictWinModel? predictionData;
    
    // Check if we have both 'ques' and 'data' fields at root level
    if (json['ques'] != null && json['data'] != null) {
      predictionData = PredictWinModel.fromJson(json);
    }
    
    return PredictWinResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: predictionData,
    );
  }

  bool get isSuccess => success == 1;
}



class SubmitPredictionRequest {
  final int id;
  final String answer;
  final String recipient;
  final int ques;

  SubmitPredictionRequest({
    required this.id,
    required this.answer,
    required this.recipient,
    required this.ques,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'answer': answer,
      'recipient': recipient,
      'ques': ques,
    };
  }
}

class SubmitPredictionResponse {
  final int success;
  final String message;
  final dynamic data;

  SubmitPredictionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SubmitPredictionResponse.fromJson(Map<String, dynamic> json) {
    return SubmitPredictionResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  bool get isSuccess => success == 1;
}
