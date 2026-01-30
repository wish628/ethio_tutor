import 'dart:convert';

/// Vocabulary word for flashcard practice
class VocabularyWord {
  final String id;
  final String word; // In target language (Amharic/Oromo)
  final String translation; // English translation
  final String? pronunciation; // Pronunciation guide
  final String? exampleSentence; // Example usage
  final String languageCode; // 'am' or 'om'
  final VocabularyCategory category;
  
  // Spaced repetition data
  int masteryLevel; // 0-5, higher = better mastered
  DateTime? nextReviewDate;
  int reviewCount;
  double easeFactor; // For spaced repetition algorithm

  VocabularyWord({
    required this.id,
    required this.word,
    required this.translation,
    this.pronunciation,
    this.exampleSentence,
    required this.languageCode,
    required this.category,
    this.masteryLevel = 0,
    this.nextReviewDate,
    this.reviewCount = 0,
    this.easeFactor = 2.5,
  });

  /// Update review data after practice
  void updateReview(ReviewQuality quality) {
    reviewCount++;
    
    // Update ease factor based on quality
    switch (quality) {
      case ReviewQuality.perfect:
        easeFactor += 0.1;
        masteryLevel = (masteryLevel + 1).clamp(0, 5);
        break;
      case ReviewQuality.good:
        masteryLevel = (masteryLevel + 1).clamp(0, 5);
        break;
      case ReviewQuality.okay:
        // No change to mastery
        break;
      case ReviewQuality.hard:
        easeFactor -= 0.15;
        masteryLevel = (masteryLevel - 1).clamp(0, 5);
        break;
      case ReviewQuality.again:
        easeFactor -= 0.2;
        masteryLevel = 0;
        break;
    }

    // Clamp ease factor
    easeFactor = easeFactor.clamp(1.3, 2.5);

    // Calculate next review date based on mastery level
    final now = DateTime.now();
    switch (masteryLevel) {
      case 0:
        nextReviewDate = now; // Review immediately
        break;
      case 1:
        nextReviewDate = now.add(Duration(days: 1));
        break;
      case 2:
        nextReviewDate = now.add(Duration(days: 3));
        break;
      case 3:
        nextReviewDate = now.add(Duration(days: 7));
        break;
      case 4:
        nextReviewDate = now.add(Duration(days: 14));
        break;
      case 5:
        nextReviewDate = now.add(Duration(days: 30));
        break;
    }
  }

  /// Check if word needs review
  bool needsReview() {
    if (nextReviewDate == null) return true;
    return DateTime.now().isAfter(nextReviewDate!);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'pronunciation': pronunciation,
      'exampleSentence': exampleSentence,
      'languageCode': languageCode,
      'category': category.name,
      'masteryLevel': masteryLevel,
      'nextReviewDate': nextReviewDate?.toIso8601String(),
      'reviewCount': reviewCount,
      'easeFactor': easeFactor,
    };
  }

  /// Create from JSON
  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id'],
      word: json['word'],
      translation: json['translation'],
      pronunciation: json['pronunciation'],
      exampleSentence: json['exampleSentence'],
      languageCode: json['languageCode'],
      category: VocabularyCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => VocabularyCategory.general,
      ),
      masteryLevel: json['masteryLevel'] ?? 0,
      nextReviewDate: json['nextReviewDate'] != null
          ? DateTime.parse(json['nextReviewDate'])
          : null,
      reviewCount: json['reviewCount'] ?? 0,
      easeFactor: (json['easeFactor'] ?? 2.5).toDouble(),
    );
  }
}

enum VocabularyCategory {
  greetings,
  numbers,
  food,
  family,
  travel,
  shopping,
  general,
}

enum ReviewQuality {
  again,   // Didn't know it
  hard,    // Knew it with difficulty
  okay,    // Knew it (okay)
  good,    // Knew it (good)
  perfect, // Knew it perfectly
}
