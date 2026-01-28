import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LessonScreen extends StatefulWidget {
  final String languageCode;
  final String languageName;
  final AIService aiService;

  const LessonScreen({
    super.key,
    required this.languageCode,
    required this.languageName,
    required this.aiService,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isLoading = false;
  String _lessonContent = '';
  String _userResponse = '';
  double _speechSpeed = 1.0;
  bool _voiceFeedbackEnabled = true;

  final List<Map<String, String>> _basicPhrases = [
    {'amharic': 'ሰላም', 'oromo': 'Akkam', 'translation': 'Hello'},
    {'amharic': 'እመሰገናለሁ', 'oromo': 'Mul\'ata', 'translation': 'Thank you'},
    {'amharic': 'እንደምን አለህ?', 'oromo': 'Waa sani?', 'translation': 'How are you?'},
    {'amharic': 'አመሰግናለሁ', 'oromo': 'Galatoomi', 'translation': 'You\'re welcome'},
    {'amharic': 'አገራችሁ', 'oromo': 'Biyyana', 'translation': 'Welcome'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _speechSpeed = prefs.getDouble('speechSpeed') ?? 1.0;
      _voiceFeedbackEnabled = prefs.getBool('voiceFeedback') ?? true;
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playTextToSpeech(String text) async {
    if (!_voiceFeedbackEnabled) return; // Skip if voice feedback is disabled
    
    try {
      final audioFile = await widget.aiService.textToSpeech(text, widget.languageCode);
      await _player.setFilePath(audioFile.path);
      await _player.setSpeed(_speechSpeed); // Apply user's preferred speech speed
      await _player.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  Future<void> _getPracticePrompt() async {
    setState(() {
      _isLoading = true;
      _lessonContent = '';
    });

    try {
      final prompt = "Give me a simple ${widget.languageName} phrase to practice, "
          "along with its English translation. Respond in this format: "
          "Phrase: [phrase], Translation: [english translation], "
          "Pronunciation: [pronunciation guide]";
      
      final response = await widget.aiService.getAIResponse(prompt, widget.languageCode);
      setState(() {
        _lessonContent = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting lesson: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learn ${widget.languageName}', style: GoogleFonts.notoSansEthiopic()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Phrases',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ..._basicPhrases.map((phrase) {
                      final textToShow = widget.languageCode == 'am' 
                          ? phrase['amharic']! 
                          : phrase['oromo']!;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    textToShow,
                                    style: GoogleFonts.notoSansEthiopic(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    phrase['translation']!,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up),
                              onPressed: () => _playTextToSpeech(textToShow),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Practice Session',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      if (_lessonContent.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(_lessonContent),
                        )
                      else
                        const Text('Click the button below to start practicing.'),
                      
                      ElevatedButton(
                        onPressed: _getPracticePrompt,
                        child: const Text('Get Practice Phrase'),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Your response in ${widget.languageName}',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          setState(() {
                            _userResponse = value;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ElevatedButton(
                        onPressed: _userResponse.isEmpty ? null : () async {
                          setState(() {
                            _isLoading = true;
                          });
                          
                          try {
                            final response = await widget.aiService.getAIResponse(
                              "Correct my phrase: $_userResponse",
                              widget.languageCode,
                            );
                            
                            setState(() {
                              _lessonContent = response;
                              _isLoading = false;
                            });
                          } catch (e) {
                            setState(() {
                              _isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        child: const Text('Check My Pronunciation'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}