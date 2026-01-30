import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'ai_service.dart';
import 'utils/temp_file_cleanup.dart';
import 'screens/home_screen.dart';
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

class EthioTutorApp extends StatelessWidget {
  final AIService ai;

  const EthioTutorApp({super.key, required this.ai});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ethio Tutor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: HomeScreen(ai: ai),
    );
  }
}
