class LeaderboardModel {
  final int success;
  final String message;
  final int rank;
  final List<LeaderboardUser> leaderboard;

  LeaderboardModel({
    required this.success,
    required this.message,
    required this.rank,
    required this.leaderboard,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    var dataList = (json['data'] as List?) ?? [];
    // Ensure sequential indexing if ranks are missing/zero
    for (int i = 0; i < dataList.length; i++) {
      if (dataList[i] is Map<String, dynamic>) {
        var r = dataList[i]['rank'];
        if (r == null || r == 0 || r == '0') {
          dataList[i]['rank'] = i + 1;
        }
      }
    }

    return LeaderboardModel(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      rank: json['rank'] ?? 0,
      leaderboard:
          dataList.map((user) => LeaderboardUser.fromJson(user)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'rank': rank,
      'data': leaderboard.map((user) => user.toJson()).toList(),
    };
  }
}

class LeaderboardUser {
  final int rank;
  final String userName;
  final String fullName;
  final String avatar;
  final dynamic points; // Can be int or string from API

  LeaderboardUser({
    required this.rank,
    required this.userName,
    required this.fullName,
    required this.avatar,
    required this.points,
  });

  // Get points as integer
  int get pointsValue {
    if (points is int) return points;
    if (points is String) return int.tryParse(points) ?? 0;
    return 0;
  }

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      rank: json['rank'] is int
          ? json['rank']
          : int.tryParse(json['rank']?.toString() ?? '0') ?? 0,
      userName: json['user_name'] ?? json['username'] ?? '',
      fullName: json['full_name'] ?? 'N/A',
      avatar: json['avatar'] ?? json['profile_picture'] ?? '',
      points: json['points'] ?? json['score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user_name': userName,
      'full_name': fullName,
      'avatar': avatar,
      'points': points,
    };
  }
}
