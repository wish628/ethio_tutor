import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'ai_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_screen.dart';
import 'lesson_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ethio_tutor/utils/temp_file_cleanup.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load env and create AIService before the UI starts so apiKey is available.
  await dotenv.load(fileName: '.env');
  // Clean old temp files at startup to reduce disk usage.
  try {
    final temp = await getTemporaryDirectory();
    await cleanOldTempFiles(temp);
  } catch (_) {}
  final ai = await AIService.fromEnv();
  runApp(MaterialApp(home: ChatScreen(ai: ai)));
}

class ChatScreen extends StatefulWidget {
  final AIService ai;

  const ChatScreen({super.key, required this.ai});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Record recorder = Record();
  final AudioPlayer player = AudioPlayer();

  String chatLog = "Welcome! Press and hold the mic to speak in Amharic or Oromo. The AI tutor will respond with corrections and feedback.";
  String currentLang = "am"; // Default to Amharic
  double _speechSpeed = 1.0;
  bool _voiceFeedbackEnabled = true;

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
      // Request microphone permission at runtime with a rationale.
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
      }

      if (status.isGranted) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/user_input_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await recorder.start(path: path);
        setState(() {
          chatLog = 'Recording...';
        });
      } else {
        setState(() {
          chatLog = 'Microphone permission not granted.';
        });
        // Show a dialog guiding the user to app settings.
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
      if (path == null || path.isEmpty) {
        setState(() => chatLog = "No audio recorded. Please try again.");
        return;
      }
      
      setState(() => chatLog = "Processing your speech...");

      // Send the recorded audio file to Addis AI STT (Speech-to-Text)
      String transcribedText;
      try {
        transcribedText = await widget.ai.speechToText(path, currentLang);
      } catch (e) {
        setState(() => chatLog = "Error transcribing audio. Please try again.");
        return;
      }

      setState(() => chatLog = "You said: $transcribedText\n\nGetting AI response...");

      // Send transcribed text to AI for tutoring feedback with retry logic
      String responseText;
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

      // Play AI Voice response with error handling (if enabled)
      if (_voiceFeedbackEnabled) {
        try {
          var audioFile = await widget.ai.textToSpeech(responseText, currentLang);
          await player.setFilePath(audioFile.path);
          await player.setSpeed(_speechSpeed); // Apply user's preferred speech speed
          await player.play();
        } catch (e) {
          // Text is already shown, so audio failure is not critical
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButton<String>(
                  value: currentLang,
                  items: [
                    const DropdownMenuItem(value: "am", child: Text("Amharic (አማርኛ)")),
                    const DropdownMenuItem(value: "om", child: Text("Oromo (Afaan Oromo)")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => currentLang = val);
                    }
                  },
                ),
                const SizedBox(height: 8),
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
                  label: const Text("Lessons"),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  chatLog, 
                  style: GoogleFonts.notoSansEthiopic(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: GestureDetector(
              onLongPressStart: (_) => _startListening(),
              onLongPressEnd: (_) => _stopListening(),
              child: CircleAvatar(
                radius: 40, 
                backgroundColor: Colors.blue,
                child: Icon(Icons.mic, size: 40, color: Colors.white),
              ),
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