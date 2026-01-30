import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vocabulary_word.dart';

/// Service for managing vocabulary and flashcard practice
class VocabularyService {
  static const String _vocabularyKey = 'vocabulary_data';
  
  List<VocabularyWord>? _cachedWords;

  /// Load vocabulary from assets and user progress
  Future<List<VocabularyWord>> loadVocabulary(String languageCode) async {
    if (_cachedWords != null) {
      return _cachedWords!.where((w) => w.languageCode == languageCode).toList();
    }

    // Load base vocabulary from assets
    final baseWords = await _loadBaseVocabulary(languageCode);
    
    // Load user progress for these words
    final userProgress = await _loadUserProgress();
    
    // Merge base vocabulary with user progress
    final mergedWords = <VocabularyWord>[];
    for (final baseWord in baseWords) {
      final userWord = userProgress[baseWord.id];
      if (userWord != null) {
        // Use user's progress
        mergedWords.add(userWord);
      } else {
        // New word, add to list
        mergedWords.add(baseWord);
      }
    }

    _cachedWords = mergedWords;
    return mergedWords.where((w) => w.languageCode == languageCode).toList();
  }

  /// Load base vocabulary from assets
  Future<List<VocabularyWord>> _loadBaseVocabulary(String languageCode) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/vocabulary/${languageCode}_basic.json'
      );
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => VocabularyWord.fromJson(json)).toList();
    } catch (e) {
      // If asset file doesn't exist, return hardcoded basic words
      return _getHardcodedVocabulary(languageCode);
    }
  }

  /// Hardcoded vocabulary as fallback
  List<VocabularyWord> _getHardcodedVocabulary(String languageCode) {
    if (languageCode == 'am') {
      return [
        VocabularyWord(
          id: 'am_hello',
          word: 'ሰላም',
          translation: 'Hello',
          pronunciation: 'selam',
          languageCode: 'am',
          category: VocabularyCategory.greetings,
        ),
        VocabularyWord(
          id: 'am_thank_you',
          word: 'አመሰግናለሁ',
          translation: 'Thank you',
          pronunciation: 'ameseginalehu',
          languageCode: 'am',
          category: VocabularyCategory.greetings,
        ),
        VocabularyWord(
          id: 'am_yes',
          word: 'አዎ',
          translation: 'Yes',
          pronunciation: 'awo',
          languageCode: 'am',
          category: VocabularyCategory.general,
        ),
        VocabularyWord(
          id: 'am_no',
          word: 'አይ',
          translation: 'No',
          pronunciation: 'ay',
          languageCode: 'am',
          category: VocabularyCategory.general,
        ),
        VocabularyWord(
          id: 'am_water',
          word: 'ውሃ',
          translation: 'Water',
          pronunciation: 'wuha',
          languageCode: 'am',
          category: VocabularyCategory.food,
        ),
      ];
    } else if (languageCode == 'om') {
      return [
        VocabularyWord(
          id: 'om_hello',
          word: 'Akkam',
          translation: 'Hello',
          pronunciation: 'akkam',
          languageCode: 'om',
          category: VocabularyCategory.greetings,
        ),
        VocabularyWord(
          id: 'om_thank_you',
          word: 'Galatoomi',
          translation: 'Thank you',
          pronunciation: 'galatoomi',
          languageCode: 'om',
          category: VocabularyCategory.greetings,
        ),
        VocabularyWord(
          id: 'om_yes',
          word: 'Eeyyee',
          translation: 'Yes',
          pronunciation: 'eeyyee',
          languageCode: 'om',
          category: VocabularyCategory.general,
        ),
        VocabularyWord(
          id: 'om_no',
          word: 'Lakki',
          translation: 'No',
          pronunciation: 'lakki',
          languageCode: 'om',
          category: VocabularyCategory.general,
        ),
        VocabularyWord(
          id: 'om_water',
          word: 'Bishaan',
          translation: 'Water',
          pronunciation: 'bishaan',
          languageCode: 'om',
          category: VocabularyCategory.food,
        ),
      ];
    }
    return [];
  }

  /// Load user's vocabulary progress from local storage
  Future<Map<String, VocabularyWord>> _loadUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_vocabularyKey);
    
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final words = jsonList.map((json) => VocabularyWord.fromJson(json)).toList();
      return {for (var word in words) word.id: word};
    }
    
    return {};
  }

  /// Save vocabulary progress
  Future<void> saveProgress(List<VocabularyWord> words) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = words.map((w) => w.toJson()).toList();
    await prefs.setString(_vocabularyKey, jsonEncode(jsonList));
    _cachedWords = words;
  }

  /// Get words that need review
  Future<List<VocabularyWord>> getWordsForReview(String languageCode, {int limit = 20}) async {
    final allWords = await loadVocabulary(languageCode);
    final wordsNeedingReview = allWords.where((w) => w.needsReview()).toList();
    
    // Sort by next review date (earliest first)
    wordsNeedingReview.sort((a, b) {
      if (a.nextReviewDate == null && b.nextReviewDate == null) return 0;
      if (a.nextReviewDate == null) return -1;
      if (b.nextReviewDate == null) return 1;
      return a.nextReviewDate!.compareTo(b.nextReviewDate!);
    });
    
    return wordsNeedingReview.take(limit).toList();
  }

  /// Submit a review for a word
  Future<void> submitReview(VocabularyWord word, ReviewQuality quality) async {
    final allWords = await loadVocabulary(word.languageCode);
    final index = allWords.indexWhere((w) => w.id == word.id);
    
    if (index != -1) {
      word.updateReview(quality);
      allWords[index] = word;
      await saveProgress(allWords);
    }
  }

  /// Get words by category
  Future<List<VocabularyWord>> getWordsByCategory(
    String languageCode,
    VocabularyCategory category,
  ) async {
    final allWords = await loadVocabulary(languageCode);
    return allWords.where((w) => w.category == category).toList();
  }

  /// Get mastered words count
  Future<int> getMasteredWordsCount(String languageCode) async {
    final allWords = await loadVocabulary(languageCode);
    return allWords.where((w) => w.masteryLevel >= 4).length;
  }

  /// Search words
  Future<List<VocabularyWord>> searchWords(String languageCode, String query) async {
    final allWords = await loadVocabulary(languageCode);
    final lowerQuery = query.toLowerCase();
    
    return allWords.where((w) =>
      w.word.toLowerCase().contains(lowerQuery) ||
      w.translation.toLowerCase().contains(lowerQuery) ||
      (w.pronunciation?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }
}
