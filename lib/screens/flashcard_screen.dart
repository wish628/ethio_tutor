import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../services/vocabulary_service.dart';
import '../models/vocabulary_word.dart';
import '../theme/app_colors.dart';

/// Flashcard practice screen with swipe gestures
class FlashcardScreen extends StatefulWidget {
  final List<VocabularyWord> words;
  final VocabularyService vocabularyService;

  const FlashcardScreen({
    super.key,
    required this.words,
    required this.vocabularyService,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;
  bool _showTranslation = false;
  late ConfettiController _confettiController;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _nextCard(ReviewQuality quality) async {
    // Submit review
    await widget.vocabularyService.submitReview(widget.words[_currentIndex], quality);

    if (quality == ReviewQuality.good || quality == ReviewQuality.perfect) {
      _correctCount++;
    }

    if (_currentIndex < widget.words.length - 1) {
      setState(() {
        _currentIndex++;
        _showTranslation = false;
      });
    } else {
      // Session complete
      _confettiController.play();
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final accuracy = (_correctCount / widget.words.length * 100).round();
        return AlertDialog(
          title: const Text('🎉 Session Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You reviewed ${widget.words.length} words',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              CircularProgressIndicator(
                value: accuracy / 100,
                strokeWidth: 8,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation(AppColors.success),
              ),
              const SizedBox(height: 16),
              Text(
                '$accuracy% Accuracy',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to vocabulary screen
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.words[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Flashcards (${_currentIndex + 1}/${widget.words.length})',
          style: GoogleFonts.notoSansEthiopic(),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentIndex + 1) / widget.words.length,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 6,
              ),

              const SizedBox(height: 32),

              // Flashcard
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _showTranslation = !_showTranslation);
                    },
                    child: Card(
                      margin: const EdgeInsets.all(24),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _showTranslation
                                  ? Column(
                                      key: const ValueKey('translation'),
                                      children: [
                                        Text(
                                          word.translation,
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        if (word.pronunciation != null) ...[
                                          const SizedBox(height: 16),
                                          Text(
                                            word.pronunciation!,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                        if (word.exampleSentence != null) ...[
                                          const SizedBox(height: 24),
                                          Text(
                                            word.exampleSentence!,
                                            style: GoogleFonts.notoSansEthiopic(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ],
                                    )
                                  : Text(
                                      word.word,
                                      key: const ValueKey('word'),
                                      style: GoogleFonts.notoSansEthiopic(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _showTranslation
                                  ? 'Tap to see word'
                                  : 'Tap to see translation',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Answer buttons
              if (_showTranslation)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'How well did you know this word?',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildAnswerButton(
                            '❌',
                            'Again',
                            AppColors.error,
                            () => _nextCard(ReviewQuality.again),
                          ),
                          _buildAnswerButton(
                            '😐',
                            'Hard',
                            Colors.orange,
                            () => _nextCard(ReviewQuality.hard),
                          ),
                          _buildAnswerButton(
                            '✅',
                            'Good',
                            AppColors.success,
                            () => _nextCard(ReviewQuality.good),
                          ),
                          _buildAnswerButton(
                            '⭐',
                            'Perfect',
                            AppColors.accent,
                            () => _nextCard(ReviewQuality.perfect),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: const [
                AppColors.ethiopianGreen,
                AppColors.ethiopianYellow,
                AppColors.ethiopianRed,
                AppColors.accent,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(String emoji, String label, Color color, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
