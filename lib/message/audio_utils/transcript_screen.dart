import 'package:flutter/material.dart';
import 'package:hands_talks/services/Speech_to_text.dart';

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

    final result = await WhisperTranscriber.transcribeFromFirebaseUrl(widget.audioUrl);

    setState(() {
      transcription = result;
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
                child: Text(
                  "Transcribe Audio",
                  style: TextStyle(color: Colors.white, fontSize: 18),
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
