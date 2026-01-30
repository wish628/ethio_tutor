import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import '../ai_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../settings_screen.dart';
import '../lesson_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/animated_mic_button.dart';
import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import 'vocabulary_screen.dart';
import 'progress_screen.dart';

/// Main home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  final AIService ai;

  const HomeScreen({super.key, required this.ai});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  final ProgressService _progressService = ProgressService();

  @override
  void initState() {
    super.initState();
    _screens = [
      PracticeTab(ai: widget.ai, progressService: _progressService),
      VocabularyScreen(),
      ProgressScreen(progressService: _progressService),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Practice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Vocabulary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Practice tab (original chat screen functionality)
class PracticeTab extends StatefulWidget {
  final AIService ai;
  final ProgressService progressService;

  const PracticeTab({
    super.key,
    required this.ai,
    required this.progressService,
  });

  @override
  State<PracticeTab> createState() => _PracticeTabState();
}

class _PracticeTabState extends State<PracticeTab> {
  final AudioRecorder recorder = AudioRecorder();
  final AudioPlayer player = AudioPlayer();

  String chatLog = "Welcome! Press and hold the mic to speak in Amharic or Oromo. The AI tutor will respond with corrections and feedback.";
  String currentLang = "am";
  double _speechSpeed = 1.0;
  bool _voiceFeedbackEnabled = true;
  bool _isRecording = false;
  DateTime? _sessionStartTime;

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

  void _startListening() async {
    try {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
      }

      if (status.isGranted) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/user_input_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await recorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          chatLog = 'Recording...';
          _sessionStartTime = DateTime.now();
        });
      } else {
        setState(() {
          chatLog = 'Microphone permission not granted.';
        });
        _showPermissionDialog();
      }
    } catch (e) {
      setState(() {
        chatLog = "Error starting recording: $e";
      });
    }
  }

  void _showPermissionDialog() async {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone permission required'),
        content: const Text('This app needs access to the microphone to record your voice. Please enable the permission in app settings.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _stopListening() async {
    try {
      final path = await recorder.stop();
      setState(() {
        _isRecording = false;
      });

      if (path == null || path.isEmpty) {
        setState(() => chatLog = "No audio recorded. Please try again.");
        return;
      }

      setState(() => chatLog = "Processing your speech...");

      String transcribedText;
      try {
        transcribedText = await widget.ai.speechToText(path, currentLang);
      } catch (e) {
        setState(() => chatLog = "Error transcribing audio. Please try again.");
        return;
      }

      setState(() => chatLog = "You said: $transcribedText\n\nGetting AI response...");

      String responseText = "";
      int retries = 0;
      while (retries < 3) {
        try {
          responseText = await widget.ai.getAIResponse(
            "I'm learning ${currentLang == 'am' ? 'Amharic' : 'Oromo'}. I said: '$transcribedText'. "
            "Please correct my pronunciation or grammar if needed, and provide helpful feedback.",
            currentLang
          );
          break;
        } catch (e) {
          retries++;
          if (retries >= 3) {
            setState(() => chatLog = "Unable to get AI response after multiple attempts. Please check your connection.");
            return;
          }
          await Future.delayed(Duration(seconds: retries));
        }
      }

      setState(() => chatLog = "AI: $responseText");

      // Track practice session
      if (_sessionStartTime != null) {
        final duration = DateTime.now().difference(_sessionStartTime!);
        await widget.progressService.addPracticeTime(duration.inMinutes > 0 ? duration.inMinutes : 1);
        await widget.progressService.completeLesson(currentLang);
      }

      // Play AI Voice response
      if (_voiceFeedbackEnabled) {
        try {
          var audioFile = await widget.ai.textToSpeech(responseText, currentLang);
          await player.setFilePath(audioFile.path);
          await player.setSpeed(_speechSpeed);
          await player.play();
        } catch (e) {
          print("Audio playback error: $e");
        }
      }
    } catch (e) {
      setState(() {
        chatLog = "Error processing response: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ethio Tutor", style: GoogleFonts.notoSansEthiopic()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Language selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: currentLang,
                    underline: const SizedBox(),
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                        value: "am",
                        child: Text("Amharic (አማርኛ)", style: GoogleFonts.notoSansEthiopic()),
                      ),
                      DropdownMenuItem(
                        value: "om",
                        child: Text("Oromo (Afaan Oromo)", style: GoogleFonts.notoSansEthiopic()),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => currentLang = val);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Lessons button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LessonScreen(
                          languageCode: currentLang,
                          languageName: currentLang == "am" ? "Amharic" : "Oromo",
                          aiService: widget.ai,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.school),
                  label: const Text("Structured Lessons"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
          
          // Chat log display
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    chatLog,
                    style: GoogleFonts.notoSansEthiopic(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          
          // Animated mic button
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: AnimatedMicButton(
              onLongPressStart: _startListening,
              onLongPressEnd: _stopListening,
              isRecording: _isRecording,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    recorder.dispose();
    player.dispose();
    super.dispose();
  }
}
