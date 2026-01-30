# Addis AI Integration Documentation

This document explains how Ethio Tutor integrates with the Addis AI API for speech-to-text, text-to-speech, and AI tutoring features.

## Overview

Ethio Tutor uses the [Addis AI API](https://addisassistant.com) to provide:
- **Speech-to-Text (STT)**: Convert spoken Amharic/Oromo to text
- **AI Chat**: Generate intelligent tutoring responses
- **Text-to-Speech (TTS)**: Convert text responses to natural-sounding audio

## Setup

### 1. Get API Key

1. Visit [Addis Assistant](https://addisassistant.com)
2. Create an account or sign in
3. Navigate to API Settings
4. Generate a new API key
5. Copy the key for use in the app

### 2. Configure Environment Variables

Create a `.env` file in the project root:

```env
ADDIS_AI_API_KEY=your_api_key_here
BASE_URL=https://api.addisassistant.com/api/v1
```

**Security Note**: Never commit your `.env` file to version control. Add it to `.gitignore`.

### 3. Build Configuration

For local development:
```bash
flutter pub get
flutter run
```

For production builds, use GitHub Actions secrets:
1. Go to repository Settings → Secrets
2. Add `ADDIS_AI_API_KEY` secret
3. Optionally add `BASE_URL` (defaults to production URL)

## API Endpoints

### 1. Chat Generation

**Endpoint**: `POST /chat_generate`

**Purpose**: Generate AI tutoring responses

**Request**:
```json
{
  "prompt": "You are a language tutor. Correct my mistakes. I said: 'ሰላም'",
  "target_language": "am"
}
```

**Response**:
```json
{
  "response": "Great! You said 'ሰላም' which means 'Hello'. Your pronunciation is correct!"
}
```

**Implementation**:
```dart
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
    final body = jsonDecode(response.body);
    return body['response'] ?? 'Sorry, no response received';
  } else {
    throw Exception('Failed to get AI response: ${response.statusCode}');
  }
}
```

### 2. Speech-to-Text (STT)

**Endpoint**: `POST /stt`

**Purpose**: Transcribe audio recordings to text

**Request**: Multipart form data
- `audio`: Audio file (m4a, mp3, wav)
- `language`: Language code ('am' or 'om')

**Response**:
```json
{
  "transcription": "ሰላም"
}
```

**Implementation**:
```dart
Future<String> speechToText(String audioPath, String lang) async {
  final uri = Uri.parse('$baseUrl/stt');
  var request = http.MultipartRequest('POST', uri);
  request.headers['X-API-Key'] = apiKey;
  request.fields['language'] = lang;
  request.files.add(await http.MultipartFile.fromPath('audio', audioPath));

  final streamedResponse = await client.send(request);
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    return body['transcription'] ?? 'Could not transcribe audio';
  } else {
    throw Exception('Failed to transcribe audio: ${response.statusCode}');
  }
}
```

### 3. Text-to-Speech (TTS)

**Endpoint**: `POST /audio`

**Purpose**: Generate natural-sounding audio from text

**Request**:
```json
{
  "text": "ሰላም",
  "language": "am"
}
```

**Response**: Binary audio data (MP3)

**Implementation**:
```dart
Future<File> textToSpeech(String text, String lang) async {
  final uri = Uri.parse('$baseUrl/audio');
  final response = await client.post(
    uri,
    headers: {'Content-Type': 'application/json', 'X-API-Key': apiKey},
    body: jsonEncode({'text': text, 'language': lang}),
  );

  if (response.statusCode == 200) {
    final bytes = response.bodyBytes;
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/ai_voice_${DateTime.now().millisecondsSinceEpoch}.mp3');
    return await file.writeAsBytes(bytes);
  } else {
    throw Exception('Failed to convert text to speech: ${response.statusCode}');
  }
}
```

## Language Codes

- `am`: Amharic (አማርኛ)
- `om`: Afaan Oromo

## Error Handling

### Common Errors

**401 Unauthorized**
- Cause: Invalid or missing API key
- Solution: Verify your API key is correct

**429 Too Many Requests**
- Cause: Rate limit exceeded
- Solution: Implement retry logic with exponential backoff

**500 Server Error**
- Cause: API server issue
- Solution: Retry after a delay, show user-friendly error message

### Best Practices

1. **Implement Retry Logic**:
```dart
int retries = 0;
while (retries < 3) {
  try {
    final response = await api.getAIResponse(text, lang);
    return response;
  } catch (e) {
    retries++;
    if (retries >= 3) throw e;
    await Future.delayed(Duration(seconds: retries));
  }
}
```

2. **Handle Network Issues**:
```dart
try {
  final response = await api.getAIResponse(text, lang);
  return response;
} on SocketException {
  throw Exception('No internet connection');
} on TimeoutException {
  throw Exception('Request timeout');
} catch (e) {
  throw Exception('Unexpected error: $e');
}
```

3. **Graceful Degradation**:
- If TTS fails, still show text response
- If STT fails, allow manual text input
- Cache successful responses for offline reference

## Rate Limits

- **Free tier**: 100 requests/day
- **Premium tier**: 10,000 requests/day
- Rate limit resets at midnight UTC

## Testing

Use mock responses for testing:

```dart
class MockAIService extends AIService {
  @override
  Future<String> getAIResponse(String text, String lang) async {
    await Future.delayed(Duration(milliseconds: 500));
    return 'Mock response for: $text';
  }
}
```

## Support

For API-specific issues:
- Documentation: https://docs.addisassistant.com
- Support: api-support@addisassistant.com
