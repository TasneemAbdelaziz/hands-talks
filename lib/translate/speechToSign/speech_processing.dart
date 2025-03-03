import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hands_talks/theming.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechProcessing extends StatefulWidget {
  static const String routeName = "SpeechProcessing";
  @override
  State<SpeechProcessing> createState() => SpeechProcessingState();
}

class SpeechProcessingState extends State<SpeechProcessing> {
  late RecorderController recorderController;
  bool isRecording = false;
  List<double> waveformValues = [];
  Timer? timer;
  int elapsedSeconds = 0;
  // final SpeechToText _speechToText = SpeechToText();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC;

    recorderController.addListener(() {
      waveformValues = List.from(recorderController.waveData);
    });
  }

  /// Initialize speech-to-text
  // void _initSpeech() async {
  //   try {
  //     _speechEnabled = await _speechToText.initialize();
  //     print("Speech initialized: $_speechEnabled");
  //   } catch (e) {
  //     print("Error initializing speech-to-text: $e");
  //   }
  // }
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        // startRecording();
        _speech.listen(
          localeId: 'ar',
          onResult: (val) => setState(() {
            _lastWords = val.recognizedWords;
            // startRecording();

          }),
        );
      }
    } else {
      // stopRecording();
      setState(() => _isListening = false);
      _speech.stop();
      // stopRecording();

    }
  }
  /// Start listening for speech
  // void _startListening() async {
  //
  //     try {
  //       await _speechToText.listen(
  //         onResult: (result) => setState(() {
  //           _lastWords+=result.recognizedWords;
  //
  //         }),
  //         // localeId: "ar", // Set to Arabic (Egypt)
  //       );
  //       print("Started listening for speech");
  //
  //
  //     } catch (e) {
  //       print("Error starting speech recognition: $e");
  //     }
  //     print("Recognized Words: ${_lastWords}");
  // }
  //
  // /// Stop listening for speech
  // void _stopListening() async {
  //   try {
  //     await _speechToText.stop();
  //     print("Stopped listening for speech");
  //     setState(() {});
  //   } catch (e) {
  //     print("Error stopping speech recognition: $e");
  //   }
  // }

  // /// Callback for speech recognition results
  // void _onSpeechResult(SpeechRecognitionResult result) {
  //   setState(() {
  //     _lastWords +=result.recognizedWords;
  //   });
  //   print("Recognized Words: $_lastWords");
  // }

  /// Start recording audio
  Future<void> startRecording() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print("Microphone permission not granted");
      return;
    }

    await recorderController.record();
      isRecording = true;
      // _listen();
    // _startListening(); // Start speech recognition when recording starts
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds++;
      });
    });

  }

  /// Stop recording audio
  Future<void> stopRecording() async {
    List<double> finalWaveform = List.from(recorderController.waveData);

    await recorderController.pause();
    // _listen();
    // _stopListening(); // Stop speech recognition when recording stops

setState(() {
  timer?.cancel();
  isRecording = false;
  waveformValues = finalWaveform;
});


  }

  /// Delete recording
  Future<void> deleteRecording() async {
    await recorderController.stop();
    // _stopListening(); // Stop speech recognition if active

    setState(() {
      isRecording = false;
      waveformValues = [];
      elapsedSeconds = 0;
      _lastWords = ''; // Clear recognized words
    });
  }

  @override
  void dispose() {
    recorderController.dispose();
    timer?.cancel();
    // _speechToText.stop(); // Ensure speech recognition is stopped
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(7.0),
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            enableFeedback: false,
            shape: CircleBorder(),
            elevation: 3,
            child: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  painter: CurvedWaveformPainter(
                      waveform: waveformValues,
                      amplitudes: 700,
                      colorWave: Theming.searchbar),
                  child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      )),
                ),
                CustomPaint(
                  painter: CurvedWaveformPainter(
                      waveform: waveformValues,
                      amplitudes: 500,
                      colorWave: Colors.grey),
                  child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      )),
                ),
                CustomPaint(
                  painter: CurvedWaveformPainter(
                      waveform: waveformValues,
                      amplitudes: 200,
                      colorWave: Colors.black),
                  child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      )),
                )
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                SizedBox(height: 150.h),
                Text(
                  elapsedSeconds.toMMSS(),
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theming.primary),
                ),
                SizedBox(height: 20.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: AudioWaveforms(
                    enableGesture: true,
                    size: Size(MediaQuery.of(context).size.width * 0.8, 50),
                    recorderController: recorderController,
                    waveStyle: WaveStyle(
                      waveColor: Theming.primary,
                      extendWaveform: true,
                      showMiddleLine: false,
                      waveThickness: 3,
                    ),
                  ),
                ),
                // Display recognized text
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    _lastWords,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          deleteRecording();
                        },
                        iconSize: 30,
                      ),
                      IconButton(
                        onPressed:_listen,
                        icon: Icon(
                          _isListening ? Icons.stop : Icons.mic,
                        ),
                        color: Theming.primary,
                        iconSize: 50,
                      ),
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          Navigator.pushNamed(context, 'TextProcessing', arguments: {
                            "recorderController": recorderController,
                            "lastWords": _lastWords,
                          });
                        },
                        iconSize: 30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Theming.secondary,
              borderRadius: BorderRadius.vertical(
                  top: Radius.elliptical(MediaQuery.of(context).size.width, 65)),
            ),
          ),
        ],
      ),
    );
  }
}

class CurvedWaveformPainter extends CustomPainter {
  final List<double> waveform;
  final int amplitudes;
  final Color colorWave;

  CurvedWaveformPainter(
      {required this.waveform,
        required this.amplitudes,
        required this.colorWave});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..filterQuality = FilterQuality.high
      ..color = colorWave
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    double spacing = size.width / (waveform.isEmpty ? 1 : waveform.length);
    Path path = Path();
    path.moveTo(0, size.height);

    for (int i = 0; i < waveform.length; i++) {
      double x = i * spacing;
      double y = size.height - (waveform[i] * amplitudes);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CurvedWaveformPainter oldDelegate) {
    return true;
  }
}