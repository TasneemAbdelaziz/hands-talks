import 'dart:convert';
import 'package:http/http.dart' as http;

class WhisperTranscriber {
static const String _serverUrl = 'http://192.168.1.3:5000/transcribe';

  static Future<String> transcribeFromFirebaseUrl(String audioUrl) async {
    try {
      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': audioUrl}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['text'] ?? 'No text found.';
      } else {
        return 'Server Error: ${response.statusCode}\n${response.body}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
