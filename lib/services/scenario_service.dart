import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/conversation_scenario.dart';

/// Service for managing conversation scenarios
class ScenarioService {
  List<ConversationScenario>? _cachedScenarios;

  /// Load all scenarios for a language
  Future<List<ConversationScenario>> loadScenarios(String languageCode) async {
    if (_cachedScenarios != null) {
      return _cachedScenarios!
          .where((s) => s.languageCode == languageCode)
          .toList();
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/scenarios/${languageCode}_scenarios.json'
      );
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _cachedScenarios = jsonList
          .map((json) => ConversationScenario.fromJson(json))
          .toList();
    } catch (e) {
      // If asset file doesn't exist, return hardcoded scenarios
      _cachedScenarios = _getHardcodedScenarios(languageCode);
    }

    return _cachedScenarios!
        .where((s) => s.languageCode == languageCode)
        .toList();
  }

  /// Hardcoded scenarios as fallback
  List<ConversationScenario> _getHardcodedScenarios(String languageCode) {
    if (languageCode == 'am') {
      return [
        ConversationScenario(
          id: 'am_greetings_basic',
          title: 'Basic Greetings',
          description: 'Learn how to greet people in Amharic',
          languageCode: 'am',
          category: ScenarioCategory.greetings,
          difficulty: DifficultyLevel.beginner,
          steps: [
            DialogStep(
              stepNumber: 1,
              speaker: 'ai',
              text: 'ሰላም',
              translation: 'Hello',
            ),
            DialogStep(
              stepNumber: 2,
              speaker: 'user',
              text: 'ሰላም',
              translation: 'Hello',
              acceptableResponses: ['ሰላም', 'selam'],
            ),
            DialogStep(
              stepNumber: 3,
              speaker: 'ai',
              text: 'እንደምን አለህ?',
              translation: 'How are you?',
            ),
            DialogStep(
              stepNumber: 4,
              speaker: 'user',
              text: 'ደህና ነኝ አመሰግናለሁ',
              translation: 'I am fine, thank you',
              acceptableResponses: ['ደህና ነኝ', 'ደህና ነኝ አመሰግናለሁ'],
            ),
          ],
        ),
        ConversationScenario(
          id: 'am_shopping_basic',
          title: 'Shopping at the Market',
          description: 'Practice buying items at a market',
          languageCode: 'am',
          category: ScenarioCategory.shopping,
          difficulty: DifficultyLevel.beginner,
          steps: [
            DialogStep(
              stepNumber: 1,
              speaker: 'ai',
              text: 'ምን ይፈልጋሉ?',
              translation: 'What do you want?',
            ),
            DialogStep(
              stepNumber: 2,
              speaker: 'user',
              text: 'ውሃ እፈልጋለሁ',
              translation: 'I want water',
              acceptableResponses: ['ውሃ', 'ውሃ እፈልጋለሁ'],
            ),
            DialogStep(
              stepNumber: 3,
              speaker: 'ai',
              text: 'ስንት ይፈልጋሉ?',
              translation: 'How many do you want?',
            ),
            DialogStep(
              stepNumber: 4,
              speaker: 'user',
              text: 'አንድ',
              translation: 'One',
              acceptableResponses: ['አንድ', '1'],
            ),
          ],
        ),
      ];
    } else if (languageCode == 'om') {
      return [
        ConversationScenario(
          id: 'om_greetings_basic',
          title: 'Basic Greetings',
          description: 'Learn how to greet people in Oromo',
          languageCode: 'om',
          category: ScenarioCategory.greetings,
          difficulty: DifficultyLevel.beginner,
          steps: [
            DialogStep(
              stepNumber: 1,
              speaker: 'ai',
              text: 'Akkam',
              translation: 'Hello',
            ),
            DialogStep(
              stepNumber: 2,
              speaker: 'user',
              text: 'Akkam',
              translation: 'Hello',
              acceptableResponses: ['Akkam', 'akkam'],
            ),
            DialogStep(
              stepNumber: 3,
              speaker: 'ai',
              text: 'Waa sani?',
              translation: 'How are you?',
            ),
            DialogStep(
              stepNumber: 4,
              speaker: 'user',
              text: 'Nagaan. Galatoomi',
              translation: 'I am fine, thank you',
              acceptableResponses: ['Nagaan', 'Nagaan. Galatoomi'],
            ),
          ],
        ),
      ];
    }
    return [];
  }

  /// Get scenarios by category
  Future<List<ConversationScenario>> getScenariosByCategory(
    String languageCode,
    ScenarioCategory category,
  ) async {
    final allScenarios = await loadScenarios(languageCode);
    return allScenarios.where((s) => s.category == category).toList();
  }

  /// Get scenarios by difficulty
  Future<List<ConversationScenario>> getScenariosByDifficulty(
    String languageCode,
    DifficultyLevel difficulty,
  ) async {
    final allScenarios = await loadScenarios(languageCode);
    return allScenarios.where((s) => s.difficulty == difficulty).toList();
  }

  /// Get a specific scenario by ID
  Future<ConversationScenario?> getScenarioById(String id) async {
    if (_cachedScenarios == null) {
      // Load all scenarios first
      await loadScenarios('am');
      await loadScenarios('om');
    }
    
    try {
      return _cachedScenarios!.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
