import 'package:assemblyai_flutter_sdk/assemblyai_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/services/Speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';


final api = AssemblyAI('9b5eacce2b4b4696968a505076d96dee');

// Future sendAudioFileToFlask(String audioUrl) async {
//   // final api = AssemblyAI('9b5eacce2b4b4696968a505076d96dee');
//
//   final transcription = await api.submitTranscription({
//     'audio_url': audioUrl,
//     'language_code': 'ar',
//     'punctuate': true,
//   });
//   print(audioUrl);
//   print("Transs${transcription.id}");
//   final transcriptionResult = await api.getTranscription(transcription.id);
//   print(transcriptionResult.text);
//   return transcriptionResult.words;
// }


Future<String> sendAudioFileToFlask(String audioUrl) async {
  final job = await api.submitTranscription({
    'audio_url':  audioUrl,   // must be publicly downloadable
    'language_code': 'ar',    // Arabic
    'punctuate': true,        // OK – silently ignored for languages that don’t support it
  });

  while (true) {
    final resp = await api.getTranscription(job.id);

    switch (resp.status) {
      case 'completed':
        return resp.text!;            // ✅ ready
      case 'error':
        throw Exception('AssemblyAI error: ${resp.error}');
      default:                        // queued | processing
        await Future.delayed(const Duration(seconds: 3));
    }
  }
}

// Future<String?> sendAudioFileToFlask(String audioUrl) async {
//
// final transcriptionResult = await api.getTranscription('TRANSCRIPT_ID');
// print(transcriptionResult);
// }
// Future<String> sendAudioFileToFlask(String audioUrl) async {
//   // 1. نزلي الملف من الإنترنت
//   final response = await http.get(Uri.parse(audioUrl));
//   if (response.statusCode != 200) {
//     throw Exception('فشل تحميل الملف من الإنترنت: ${response.statusCode}');
//   }
//
//   // 2. احفظيه في ملف مؤقت
//   final tempDir = await getTemporaryDirectory();
//   final tempFilePath = join(tempDir.path, 'temp_audio.m4a');
//   final tempFile = File(tempFilePath);
//   await tempFile.writeAsBytes(response.bodyBytes);
//
//   // 3. ابعتيه كـ Multipart
//   var uri = Uri.parse('http://192.168.1.3:5000/transcribe-file');
//   var request = http.MultipartRequest('POST', uri);
//   request.files.add(await http.MultipartFile.fromPath('file', tempFile.path));
//
//   var streamedResponse = await request.send();
//   var responseText = await http.Response.fromStream(streamedResponse);
//
//   if (responseText.statusCode == 200) {
//     return responseText.body;
//   } else {
//     throw Exception('فشل في التفريغ: ${responseText.body}');
//   }
// }

class TranscribeScreen extends StatefulWidget {
  String audioUrl;
  @override
  _TranscribeScreenState createState() => _TranscribeScreenState();
  TranscribeScreen({super.key,required this.audioUrl});

}

class _TranscribeScreenState extends State<TranscribeScreen> {
  String transcription = '';
  bool isLoading = false;


  Future<void> handleTranscribe() async {
    setState(() => isLoading = true);

    final result = await sendAudioFileToFlask(widget.audioUrl);


    setState(() {
      transcription = result??"";
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Audio Transcriber")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InkWell(
              onTap: handleTranscribe,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "Transcribe Audio",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            if (isLoading)
              CircularProgressIndicator()
            else
              Text(
                transcription.isNotEmpty ? transcription : "Transcript will appear here.",
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}



//
// Future<String> sendAudioFileToFlask(String audioUrl) async {
//   // 1. نزلي الملف من الإنترنت
//   final response = await http.get(Uri.parse(audioUrl));
//   if (response.statusCode != 200) {
//     throw Exception('فشل تحميل الملف من الإنترنت: ${response.statusCode}');
//   }
//
//   // 2. احفظيه في ملف مؤقت
//   final tempDir = await getTemporaryDirectory();
//   final tempFilePath = join(tempDir.path, 'temp_audio.m4a');
//   final tempFile = File(tempFilePath);
//   await tempFile.writeAsBytes(response.bodyBytes);
//
//   // 3. ابعتيه كـ Multipart
//   var uri = Uri.parse('http://192.168.1.3:5000/transcribe-file');
//   var request = http.MultipartRequest('POST', uri);
//   request.files.add(await http.MultipartFile.fromPath('file', tempFile.path));
//
//   var streamedResponse = await request.send();
//   var responseText = await http.Response.fromStream(streamedResponse);
//
//   if (responseText.statusCode == 200) {
//     return responseText.body;
//   } else {
//     throw Exception('فشل في التفريغ: ${responseText.body}');
//   }
// }



// Future<String> sendToAssembly(String audioUrl) async {
//   final response = await http.post(
//     Uri.parse("http://192.168.1.3:5000/transcribe"),
//     headers: {"Content-Type": "application/json"},
//     body: jsonEncode({"url": audioUrl}),
//   );
//
//   if (response.statusCode == 200) {
//     final json = jsonDecode(response.body);
//     return json['text'];
//   } else {
//     throw Exception("فشل التفريغ: ${response.body}");
//   }
// }
