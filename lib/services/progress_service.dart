import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/achievement.dart';

/// Service for managing user progress and achievements
class ProgressService {
  static const String _progressKey = 'user_progress';
  
  UserProgress? _cachedProgress;

  /// Get current user progress
  Future<UserProgress> getProgress() async {
    if (_cachedProgress != null) {
      return _cachedProgress!;
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_progressKey);

    if (jsonString != null) {
      _cachedProgress = UserProgress.fromJsonString(jsonString);
    } else {
      _cachedProgress = UserProgress();
    }

    return _cachedProgress!;
  }

  /// Save progress to local storage
  Future<void> saveProgress(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, progress.toJsonString());
    _cachedProgress = progress;
  }

  /// Mark a lesson as completed
  Future<void> completeLesson(String languageCode) async {
    final progress = await getProgress();
    progress.completeLesson(languageCode);
    await saveProgress(progress);
    await _checkAndUnlockAchievements(progress);
  }

  /// Add practice time
  Future<void> addPracticeTime(int minutes) async {
    final progress = await getProgress();
    progress.addPracticeTime(minutes);
    await saveProgress(progress);
    await _checkAndUnlockAchievements(progress);
  }

  /// Update accuracy score
  Future<void> updateAccuracy(double accuracy) async {
    final progress = await getProgress();
    progress.updateAccuracy(accuracy);
    await saveProgress(progress);
    await _checkAndUnlockAchievements(progress);
  }

  /// Update daily streak
  Future<void> updateStreak() async {
    final progress = await getProgress();
    progress.updateStreak();
    await saveProgress(progress);
    await _checkAndUnlockAchievements(progress);
  }

  /// Check and unlock achievements based on current progress
  Future<List<Achievement>> _checkAndUnlockAchievements(UserProgress progress) async {
    final newlyUnlocked = <Achievement>[];

    for (final achievement in Achievements.all) {
      // Skip if already unlocked
      if (progress.hasAchievement(achievement.id)) {
        continue;
      }

      // Check criteria based on category
      bool shouldUnlock = false;
      switch (achievement.category) {
        case AchievementCategory.lessons:
          shouldUnlock = progress.lessonsCompleted >= achievement.requiredValue;
          break;
        case AchievementCategory.streaks:
          shouldUnlock = progress.currentStreak >= achievement.requiredValue;
          break;
        case AchievementCategory.accuracy:
          shouldUnlock = progress.averageAccuracy >= achievement.requiredValue;
          break;
        case AchievementCategory.practice:
          shouldUnlock = progress.totalPracticeMinutes >= achievement.requiredValue;
          break;
        case AchievementCategory.vocabulary:
          // Will be implemented with vocabulary service
          break;
      }

      if (shouldUnlock) {
        progress.unlockAchievement(achievement.id);
        newlyUnlocked.add(achievement);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      await saveProgress(progress);
    }

    return newlyUnlocked;
  }

  /// Get all unlocked achievements
  Future<List<Achievement>> getUnlockedAchievements() async {
    final progress = await getProgress();
    return Achievements.all
        .where((a) => progress.hasAchievement(a.id))
        .toList();
  }

  /// Get all locked achievements
  Future<List<Achievement>> getLockedAchievements() async {
    final progress = await getProgress();
    return Achievements.all
        .where((a) => !progress.hasAchievement(a.id))
        .toList();
  }

  /// Reset all progress (for testing or user request)
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
    _cachedProgress = null;
  }

  /// Get streak status
  Future<Map<String, dynamic>> getStreakStatus() async {
    final progress = await getProgress();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    bool practicedToday = false;
    if (progress.lastPracticeDate != null) {
      final lastDate = DateTime(
        progress.lastPracticeDate!.year,
        progress.lastPracticeDate!.month,
        progress.lastPracticeDate!.day,
      );
      practicedToday = lastDate == today;
    }

    return {
      'currentStreak': progress.currentStreak,
      'bestStreak': progress.bestStreak,
      'practicedToday': practicedToday,
      'lastPracticeDate': progress.lastPracticeDate,
    };
  }
}
