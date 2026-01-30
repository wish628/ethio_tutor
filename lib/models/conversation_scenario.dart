/// Conversation scenario for situational practice
class ConversationScenario {
  final String id;
  final String title;
  final String description;
  final String languageCode;
  final ScenarioCategory category;
  final List<DialogStep> steps;
  final DifficultyLevel difficulty;

  const ConversationScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.languageCode,
    required this.category,
    required this.steps,
    required this.difficulty,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'languageCode': languageCode,
      'category': category.name,
      'steps': steps.map((s) => s.toJson()).toList(),
      'difficulty': difficulty.name,
    };
  }

  /// Create from JSON
  factory ConversationScenario.fromJson(Map<String, dynamic> json) {
    return ConversationScenario(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      languageCode: json['languageCode'],
      category: ScenarioCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => ScenarioCategory.general,
      ),
      steps: (json['steps'] as List)
          .map((s) => DialogStep.fromJson(s))
          .toList(),
      difficulty: DifficultyLevel.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
    );
  }
}

/// Individual dialog step in a scenario
class DialogStep {
  final int stepNumber;
  final String speaker; // 'ai' or 'user'
  final String text; // What should be said
  final String? translation; // English translation
  final List<String>? acceptableResponses; // For user steps

  const DialogStep({
    required this.stepNumber,
    required this.speaker,
    required this.text,
    this.translation,
    this.acceptableResponses,
  });

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'speaker': speaker,
      'text': text,
      'translation': translation,
      'acceptableResponses': acceptableResponses,
    };
  }

  factory DialogStep.fromJson(Map<String, dynamic> json) {
    return DialogStep(
      stepNumber: json['stepNumber'],
      speaker: json['speaker'],
      text: json['text'],
      translation: json['translation'],
      acceptableResponses: json['acceptableResponses'] != null
          ? List<String>.from(json['acceptableResponses'])
          : null,
    );
  }
}

enum ScenarioCategory {
  greetings,
  shopping,
  restaurant,
  directions,
  hotel,
  transportation,
  general,
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
}
