/// Achievement/Badge definition
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final AchievementCategory category;
  final int requiredValue;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.category,
    required this.requiredValue,
  });

  /// Check if achievement criteria is met
  bool isUnlocked(int currentValue) {
    return currentValue >= requiredValue;
  }
}

enum AchievementCategory {
  lessons,
  streaks,
  accuracy,
  vocabulary,
  practice,
}

/// Predefined achievements
class Achievements {
  static const firstLesson = Achievement(
    id: 'first_lesson',
    title: 'First Steps',
    description: 'Complete your first lesson',
    iconPath: 'assets/achievements/first_lesson.png',
    category: AchievementCategory.lessons,
    requiredValue: 1,
  );

  static const tenLessons = Achievement(
    id: 'ten_lessons',
    title: 'Dedicated Learner',
    description: 'Complete 10 lessons',
    iconPath: 'assets/achievements/ten_lessons.png',
    category: AchievementCategory.lessons,
    requiredValue: 10,
  );

  static const fiftyLessons = Achievement(
    id: 'fifty_lessons',
    title: 'Language Enthusiast',
    description: 'Complete 50 lessons',
    iconPath: 'assets/achievements/fifty_lessons.png',
    category: AchievementCategory.lessons,
    requiredValue: 50,
  );

  static const sevenDayStreak = Achievement(
    id: 'seven_day_streak',
    title: 'Week Warrior',
    description: 'Practice for 7 days in a row',
    iconPath: 'assets/achievements/seven_day_streak.png',
    category: AchievementCategory.streaks,
    requiredValue: 7,
  );

  static const thirtyDayStreak = Achievement(
    id: 'thirty_day_streak',
    title: 'Monthly Master',
    description: 'Practice for 30 days in a row',
    iconPath: 'assets/achievements/thirty_day_streak.png',
    category: AchievementCategory.streaks,
    requiredValue: 30,
  );

  static const perfectAccuracy = Achievement(
    id: 'perfect_accuracy',
    title: 'Perfectionist',
    description: 'Achieve 100% accuracy in a lesson',
    iconPath: 'assets/achievements/perfect_accuracy.png',
    category: AchievementCategory.accuracy,
    requiredValue: 100,
  );

  static const hundredWords = Achievement(
    id: 'hundred_words',
    title: 'Vocabulary Builder',
    description: 'Master 100 vocabulary words',
    iconPath: 'assets/achievements/hundred_words.png',
    category: AchievementCategory.vocabulary,
    requiredValue: 100,
  );

  static const hourOfPractice = Achievement(
    id: 'hour_of_practice',
    title: 'Time Invested',
    description: 'Practice for a total of 60 minutes',
    iconPath: 'assets/achievements/hour_of_practice.png',
    category: AchievementCategory.practice,
    requiredValue: 60,
  );

  /// List of all achievements
  static const List<Achievement> all = [
    firstLesson,
    tenLessons,
    fiftyLessons,
    sevenDayStreak,
    thirtyDayStreak,
    perfectAccuracy,
    hundredWords,
    hourOfPractice,
  ];

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
