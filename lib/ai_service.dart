import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:ethio_tutor/utils/temp_file_cleanup.dart';

/// AIService is a thin wrapper around the Addis AI HTTP API.
///
/// Notes:
/// - This class is test-friendly: you may provide your own [http.Client]
///   and a custom [tempDirGetter] for TTS file placement.
class AIService {
  final String apiKey;
  final String baseUrl;
  final http.Client client;
  final Future<Directory> Function() tempDirGetter;

  AIService({
    required this.apiKey,
    this.baseUrl = 'https://api.addisassistant.com/api/v1',
    http.Client? client,
    Future<Directory> Function()? tempDirGetter,
  })  : client = client ?? http.Client(),
        tempDirGetter = tempDirGetter ?? getTemporaryDirectory;

  /// Create an instance by loading environment variables from `.env`.
  /// Make sure to call this from an async context (e.g., `main()`),
  /// since it will call `dotenv.load()`.
  static Future<AIService> fromEnv({http.Client? client, String envFile = '.env'}) async {
    await dotenv.load(fileName: envFile);
    final key = dotenv.env['ADDIS_AI_API_KEY'] ?? '';
    final url = dotenv.env['BASE_URL'] ?? 'https://api.addisassistant.com/api/v1';
    return AIService(apiKey: key, baseUrl: url, client: client);
  }

  // 1. Send text or voice to AI and get a text response
  Future<String> getAIResponse(String text, String lang) async {
    final uri = Uri.parse('$baseUrl/chat_generate');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json', 'X-API-Key': apiKey},
      body: jsonEncode({
        'prompt': 'You are a language tutor. Correct my mistakes. $text',
        'target_language': lang,
      }),
    );

    if (response.statusCode == 200) {
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('response')) {
          return body['response'] ?? 'Sorry, no response received';
        }
        // Fallback: if API returns a plain string or different shape
        return body.toString();
      } catch (e) {
        // Not JSON — return raw body
        return response.body;
      }
    } else {
      // Include body in exception for easier debugging during development
      throw Exception('Failed to get AI response: ${response.statusCode} ${response.body}');
    }
  }

  // 1.5. Speech-to-Text: Convert recorded audio to text
  Future<String> speechToText(String audioPath, String lang) async {
    final uri = Uri.parse('$baseUrl/stt');
    final file = File(audioPath);
    
    if (!await file.exists()) {
      throw Exception('Audio file not found: $audioPath');
    }

    var request = http.MultipartRequest('POST', uri);
    request.headers['X-API-Key'] = apiKey;
    request.fields['language'] = lang;
    request.files.add(await http.MultipartFile.fromPath('audio', audioPath));

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('transcription')) {
          return body['transcription'] ?? 'Could not transcribe audio';
        }
        // Alternative field names the API might use
        if (body is Map && body.containsKey('text')) {
          return body['text'] ?? 'Could not transcribe audio';
        }
        return body.toString();
      } catch (e) {
        // Not JSON — return raw body
        return response.body;
      }
    } else {
      throw Exception('Failed to transcribe audio: ${response.statusCode} ${response.body}');
    }
  }

  // 2. Convert AI Text response to Audio (TTS)
  Future<File> textToSpeech(String text, String lang) async {
    final uri = Uri.parse('$baseUrl/audio');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json', 'X-API-Key': apiKey},
      body: jsonEncode({'text': text, 'language': lang}),
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final directory = await tempDirGetter();
      final file = File('${directory.path}/ai_voice_${DateTime.now().millisecondsSinceEpoch}.mp3');
  final out = await file.writeAsBytes(bytes);
  // Fire-and-forget: clean old temp files to avoid accumulation.
  Future.microtask(() => cleanOldTempFiles(directory));
      return out;
    } else {
      throw Exception('Failed to convert text to speech: ${response.statusCode} ${response.body}');
    }
  }
}