class LeaderboardModel {
  final int success;
  final String message;
  final int rank;
  final List<LeaderboardUser> leaderboard;

  final List<LeaderboardFaq>? faqs;
  final List<LeaderboardWinnerStory>? winnerStories;
  final String? banner;

  List<LeaderboardFaq> get safeFaqs => faqs ?? const [];
  List<LeaderboardWinnerStory> get safeWinnerStories =>
      winnerStories ?? const [];
  String get safeBanner => banner ?? '';

  LeaderboardModel({
    required this.success,
    required this.message,
    required this.rank,
    required this.leaderboard,
    this.faqs,
    this.winnerStories,
    this.banner,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    var dataList = (json['data'] as List?) ?? [];
    for (int i = 0; i < dataList.length; i++) {
      if (dataList[i] is Map<String, dynamic>) {
        var r = dataList[i]['rank'];
        if (r == null || r == 0 || r == '0') {
          dataList[i]['rank'] = i + 1;
        }
      }
    }

    var faqsList = (json['faqs'] as List?) ?? [];
    var storiesList = (json['winner_stories'] as List?) ?? [];

    return LeaderboardModel(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      rank: json['rank'] ?? 0,
      leaderboard:
          dataList.map((user) => LeaderboardUser.fromJson(user)).toList(),
      faqs: faqsList.map((f) => LeaderboardFaq.fromJson(f)).toList(),
      winnerStories:
          storiesList.map((s) => LeaderboardWinnerStory.fromJson(s)).toList(),
      banner: json['banner']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'rank': rank,
      'data': leaderboard.map((user) => user.toJson()).toList(),
      'faqs': safeFaqs.map((f) => f.toJson()).toList(),
      'winner_stories': safeWinnerStories.map((s) => s.toJson()).toList(),
      'banner': safeBanner,
    };
  }
}

class LeaderboardFaq {
  final int id;
  final String question;
  final String answer;
  final String category;
  final int sortOrder;

  LeaderboardFaq({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.sortOrder,
  });

  factory LeaderboardFaq.fromJson(Map<String, dynamic> json) {
    return LeaderboardFaq(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      sortOrder: json['sort_order'] is int
          ? json['sort_order']
          : int.tryParse(json['sort_order']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'sort_order': sortOrder,
    };
  }
}

class LeaderboardWinnerStory {
  final int id;
  final String title;
  final String tag;
  final String youtubeUrl;
  final String youtubeVideoId;
  final String thumbnailUrl;
  final String winnerName;
  final String description;
  final int sortOrder;
  final String computedThumbnailUrl;

  LeaderboardWinnerStory({
    required this.id,
    required this.title,
    required this.tag,
    required this.youtubeUrl,
    required this.youtubeVideoId,
    required this.thumbnailUrl,
    required this.winnerName,
    required this.description,
    required this.sortOrder,
    required this.computedThumbnailUrl,
  });

  String get effectiveThumbnail {
    if (thumbnailUrl.isNotEmpty) return thumbnailUrl;
    if (computedThumbnailUrl.isNotEmpty) return computedThumbnailUrl;
    if (youtubeVideoId.isNotEmpty) {
      return 'https://img.youtube.com/vi/$youtubeVideoId/hqdefault.jpg';
    }
    return '';
  }

  factory LeaderboardWinnerStory.fromJson(Map<String, dynamic> json) {
    return LeaderboardWinnerStory(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      tag: json['tag']?.toString() ?? '',
      youtubeUrl: json['youtube_url']?.toString() ?? '',
      youtubeVideoId: json['youtube_video_id']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString() ?? '',
      winnerName: json['winner_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      sortOrder: json['sort_order'] is int
          ? json['sort_order']
          : int.tryParse(json['sort_order']?.toString() ?? '0') ?? 0,
      computedThumbnailUrl: json['computed_thumbnail_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tag': tag,
      'youtube_url': youtubeUrl,
      'youtube_video_id': youtubeVideoId,
      'thumbnail_url': thumbnailUrl,
      'winner_name': winnerName,
      'description': description,
      'sort_order': sortOrder,
      'computed_thumbnail_url': computedThumbnailUrl,
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
