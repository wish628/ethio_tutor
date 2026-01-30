import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/vocabulary_service.dart';
import '../models/vocabulary_word.dart';
import '../theme/app_colors.dart';
import 'flashcard_screen.dart';

/// Vocabulary browser screen
class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final VocabularyService _vocabularyService = VocabularyService();
  String _selectedLanguage = 'am';
  VocabularyCategory? _selectedCategory;
  List<VocabularyWord> _words = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
  }

  Future<void> _loadVocabulary() async {
    setState(() => _isLoading = true);

    if (_searchQuery.isNotEmpty) {
      final results = await _vocabularyService.searchWords(_selectedLanguage, _searchQuery);
      setState(() {
        _words = results;
        _isLoading = false;
      });
    } else if (_selectedCategory != null) {
      final words = await _vocabularyService.getWordsByCategory(_selectedLanguage, _selectedCategory!);
      setState(() {
        _words = words;
        _isLoading = false;
      });
    } else {
      final words = await _vocabularyService.loadVocabulary(_selectedLanguage);
      setState(() {
        _words = words;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vocabulary', style: GoogleFonts.notoSansEthiopic()),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search words...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _loadVocabulary();
              },
            ),
          ),

          // Language selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Amharic'),
                    selected: _selectedLanguage == 'am',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedLanguage = 'am');
                        _loadVocabulary();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Oromo'),
                    selected: _selectedLanguage == 'om',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedLanguage = 'om');
                        _loadVocabulary();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Word list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _words.isEmpty
                    ? const Center(child: Text('No words found'))
                    : ListView.builder(
                        itemCount: _words.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final word = _words[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                word.word,
                                style: GoogleFonts.notoSansEthiopic(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(word.translation),
                                  if (word.pronunciation != null)
                                    Text(
                                      word.pronunciation!,
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: _buildMasteryIndicator(word.masteryLevel),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startFlashcardPractice,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Practice'),
      ),
    );
  }

  Widget _buildMasteryIndicator(int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getMasteryColor(level),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getMasteryLabel(level),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getMasteryColor(int level) {
    if (level >= 4) return AppColors.success;
    if (level >= 2) return AppColors.warning;
    return AppColors.error;
  }

  String _getMasteryLabel(int level) {
    if (level >= 4) return 'Mastered';
    if (level >= 2) return 'Learning';
    return 'New';
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter by Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All'),
                leading: Radio<VocabularyCategory?>(
                  value: null,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                    Navigator.pop(context);
                    _loadVocabulary();
                  },
                ),
              ),
              ...VocabularyCategory.values.map((category) {
                return ListTile(
                  title: Text(category.name.toUpperCase()),
                  leading: Radio<VocabularyCategory?>(
                    value: category,
                    groupValue: _selectedCategory,
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                      Navigator.pop(context);
                      _loadVocabulary();
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startFlashcardPractice() async {
    final wordsToReview = await _vocabularyService.getWordsForReview(_selectedLanguage);
    
    if (wordsToReview.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No words to review right now!')),
      );
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardScreen(
          words: wordsToReview,
          vocabularyService: _vocabularyService,
        ),
      ),
    );
  }
}
