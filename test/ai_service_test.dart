import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ethio_tutor/ai_service.dart';

void main() {
  test('AIService.getAIResponse parses response.response', () async {
    final mockClient = MockClient((request) async {
      if (request.url.path.endsWith('/chat_generate')) {
        return http.Response('{"response": "Hello from AI"}', 200);
      }
      return http.Response('Not Found', 404);
    });

    final ai = AIService(apiKey: 'test', client: mockClient, tempDirGetter: () async => Directory.systemTemp.createTempSync());
    final resp = await ai.getAIResponse('Hi', 'am');
    expect(resp, 'Hello from AI');
  });

  test('AIService.getAIResponse returns raw body on non-json', () async {
    final mockClient = MockClient((request) async {
      return http.Response('plain text response', 200);
    });

    final ai = AIService(apiKey: 'test', client: mockClient, tempDirGetter: () async => Directory.systemTemp.createTempSync());
    final resp = await ai.getAIResponse('Hi', 'am');
    expect(resp, 'plain text response');
  });

  test('AIService.getAIResponse throws on 500 with body included', () async {
    final mockClient = MockClient((request) async {
      return http.Response('server error details', 500);
    });

    final ai = AIService(apiKey: 'test', client: mockClient, tempDirGetter: () async => Directory.systemTemp.createTempSync());
    expect(() => ai.getAIResponse('Hi', 'am'), throwsA(predicate((e) => e.toString().contains('500') && e.toString().contains('server error details'))));
  });
}
