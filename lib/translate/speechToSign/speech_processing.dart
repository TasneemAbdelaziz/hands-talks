import 'dart:async';
import 'dart:math';
 import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hands_talks/theming.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechProcessing extends StatefulWidget {
  static const String routeName = "SpeechProcessing";
  @override
  State<SpeechProcessing> createState() => SpeechProcessingState();
}

class SpeechProcessingState extends State<SpeechProcessing> {
  bool isRecording = false;
  List<double> waveformValues = List.generate(50, (index) => 0);
  List<double> waveformValuesLine = List.generate(50, (index) => 0);
  Timer? timer;
  int elapsedSeconds = 0;
  Timer? _waveformTimer;
  late stt.SpeechToText _speech;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

  }

  void _listen() async {
    // if (_speech.isListening) {
    //   await _speech.stop(); // Ensure it stops before restarting
    // }

    bool available = await _speech.initialize(
      onStatus: (val) {
        print('onStatus: $val');
        if (val == "done" || val == "notListening") {
          _restartListening();
        }
      },
      onError: (val) {
        print('onError: $val');
        CircularProgressIndicator();
        _restartListening();
      },
    );

    if (available) {
      isRecording = true;
      _speech.listen(
        localeId: 'ar', // Arabic language
        onResult: (val) => setState(() {
          _lastWords = val.recognizedWords;
        }),
      );
    }
  }

  void _restartListening() {
    if (!_speech.isListening && isRecording == true) {
      print("Restarting listening...");
      _listen();
    }
  }

  void _startWaveformAnimation() {
    _waveformTimer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      setState(() {
        waveformValues = List.generate(10, (index) => Random().nextDouble());
        waveformValuesLine =
            List.generate(50, (index) => Random().nextDouble());
      });
    });
  }

  ///stop recording
  Future<void> stopRecording() async {
    await _speech.stop();
    setState(() {
      isRecording = false;
      timer!.cancel();
      _waveformTimer?.cancel();
    });
  }

  /// Delete recording
  Future<void> deleteRecording() async {
    await stopRecording();
    setState(() {
      waveformValues = [];
      elapsedSeconds = 0;
      _lastWords = ''; // Clear recognized words
      _waveformTimer?.cancel();
      waveformValues = List.generate(10, (index) => 0); // Reset waveform
      waveformValuesLine = List.generate(50, (index) => 0); // Reset waveform
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
    _waveformTimer?.cancel();
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
                      amplitudes: 500,
                      colorWave: Theming.searchbar),
                  child: Container(
                      decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  )),
                ),
                CustomPaint(
                  painter: CurvedWaveformPainter(
                      waveform: waveformValues,
                      amplitudes: 300,
                      colorWave: Colors.grey),
                  child: Container(
                      decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  )),
                ),
                CustomPaint(
                  painter: CurvedWaveformPainter(
                      waveform: waveformValues,
                      amplitudes: 100,
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
                    "${(elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(elapsedSeconds % 60).toString().padLeft(2, '0')}",
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
                    child: CustomPaint(
                      size: Size(MediaQuery.of(context).size.width * 0.8,
                          50), // Adjust size as needed
                      painter: WaveformPainter(waveformValuesLine),
                    )),
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
                        onPressed: () async {
                          if (isRecording == true) {
                            await stopRecording();
                          } else {
                            _listen();
                            _startWaveformAnimation();
                            timer = Timer.periodic(const Duration(seconds: 1),
                                (timer) {
                              setState(() {
                                elapsedSeconds++;
                              });
                            });
                          }
                        },
                        icon: Icon(
                          isRecording ? Icons.stop : Icons.mic,
                        ),
                        color: Theming.primary,
                        iconSize: 50,
                      ),
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          Navigator.pushNamed(context, 'TextProcessing',
                              arguments: {
                                "waveformValues": waveformValuesLine,
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
                  top:
                      Radius.elliptical(MediaQuery.of(context).size.width, 65)),
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

class WaveformPainter extends CustomPainter {
  final List<double> waveformValues;

  WaveformPainter(this.waveformValues);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue[900]! // Dark blue color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    final double barWidth = 8;
    final double spacing = 5;
    final int barCount = waveformValues.length;

    for (int i = 0; i < barCount; i++) {
      double barHeight =
          waveformValues[i] * size.height * 0.8 + size.height * 0.2;
      double x = i * (barWidth + spacing);
      canvas.drawLine(
          Offset(x, size.height - barHeight), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.waveformValues != waveformValues;
  }
}
