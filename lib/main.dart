import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_service.dart';
import 'utils/temp_file_cleanup.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Clean old temp files at startup to reduce disk usage
  try {
    final temp = await getTemporaryDirectory();
    await cleanOldTempFiles(temp);
  } catch (_) {}
  
  // Initialize AI service
  final ai = await AIService.fromEnv();
  
  runApp(EthioTutorApp(ai: ai));
}

class EthioTutorApp extends StatefulWidget {
  final AIService ai;

  const EthioTutorApp({super.key, required this.ai});

  @override
  State<EthioTutorApp> createState() => _EthioTutorAppState();
}

class _EthioTutorAppState extends State<EthioTutorApp> {
  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(ThemeMode.system);

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    _themeNotifier.value = ThemeMode.values[themeIndex];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Ethio Tutor',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeMode,
          home: SplashScreen(ai: widget.ai, themeNotifier: _themeNotifier),
        );
      },
    );
  }
}
