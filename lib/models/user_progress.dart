import 'dart:convert';

/// Tracks user's learning progress and statistics
class UserProgress {
  int lessonsCompleted;
  int currentStreak;
  int bestStreak;
  DateTime? lastPracticeDate;
  int totalPracticeMinutes;
  double averageAccuracy;
  Map<String, int> languageProgress; // Language code -> lessons completed
  List<String> unlockedAchievements;

  UserProgress({
    this.lessonsCompleted = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastPracticeDate,
    this.totalPracticeMinutes = 0,
    this.averageAccuracy = 0.0,
    Map<String, int>? languageProgress,
    List<String>? unlockedAchievements,
  })  : languageProgress = languageProgress ?? {},
        unlockedAchievements = unlockedAchievements ?? [];

  /// Update streak based on last practice date
  void updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastPracticeDate == null) {
      // First time practicing
      currentStreak = 1;
      lastPracticeDate = today;
    } else {
      final lastDate = DateTime(
        lastPracticeDate!.year,
        lastPracticeDate!.month,
        lastPracticeDate!.day,
      );

      final difference = today.difference(lastDate).inDays;

      if (difference == 0) {
        // Already practiced today, no change
        return;
      } else if (difference == 1) {
        // Consecutive day
        currentStreak++;
        lastPracticeDate = today;
      } else {
        // Streak broken
        currentStreak = 1;
        lastPracticeDate = today;
      }
    }

    // Update best streak
    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }
  }

  /// Increment lesson completion
  void completeLesson(String languageCode) {
    lessonsCompleted++;
    languageProgress[languageCode] = (languageProgress[languageCode] ?? 0) + 1;
    updateStreak();
  }

  /// Add practice time in minutes
  void addPracticeTime(int minutes) {
    totalPracticeMinutes += minutes;
  }

  /// Update average accuracy
  void updateAccuracy(double newAccuracy) {
    if (averageAccuracy == 0.0) {
      averageAccuracy = newAccuracy;
    } else {
      // Moving average
      averageAccuracy = (averageAccuracy * 0.8) + (newAccuracy * 0.2);
    }
  }

  /// Unlock an achievement
  void unlockAchievement(String achievementId) {
    if (!unlockedAchievements.contains(achievementId)) {
      unlockedAchievements.add(achievementId);
    }
  }

  /// Check if achievement is unlocked
  bool hasAchievement(String achievementId) {
    return unlockedAchievements.contains(achievementId);
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'lessonsCompleted': lessonsCompleted,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastPracticeDate': lastPracticeDate?.toIso8601String(),
      'totalPracticeMinutes': totalPracticeMinutes,
      'averageAccuracy': averageAccuracy,
      'languageProgress': languageProgress,
      'unlockedAchievements': unlockedAchievements,
    };
  }

  /// Create from JSON
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      lessonsCompleted: json['lessonsCompleted'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      lastPracticeDate: json['lastPracticeDate'] != null
          ? DateTime.parse(json['lastPracticeDate'])
          : null,
      totalPracticeMinutes: json['totalPracticeMinutes'] ?? 0,
      averageAccuracy: (json['averageAccuracy'] ?? 0.0).toDouble(),
      languageProgress: Map<String, int>.from(json['languageProgress'] ?? {}),
      unlockedAchievements: List<String>.from(json['unlockedAchievements'] ?? []),
    );
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create from JSON string
  factory UserProgress.fromJsonString(String jsonString) {
    return UserProgress.fromJson(jsonDecode(jsonString));
  }
}
