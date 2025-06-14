// // lib/translate/sign_to_text/Demo_sign_to_text.dart
import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';

import '../../theming.dart';


class SignToTextProcessing extends StatefulWidget {
  static const String routeName = 'SignToTextProcessing';

  const SignToTextProcessing({super.key});

  @override
  _SignToTextProcessingState createState() => _SignToTextProcessingState();
}

class _SignToTextProcessingState extends State<SignToTextProcessing>
    with WidgetsBindingObserver {
  CameraController? controller;
  Future<void>? initializeControllerFuture;
  String prediction = '';
  List<String> _sentence = [];
  bool isProcessing = false;
  Timer? captureTimer;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeCamera();
  }

  Future<void> initializeCamera({bool retry = false}) async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.last,
      );

      controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      initializeControllerFuture = controller!.initialize().then((_) {
        if (mounted) {
          startCapture();
        }
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera initialization error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        if (!retry) {
          initializeCamera(retry: true);
        } else {
          setState(() {
            errorMessage = 'Camera initialization failed: $e';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          });
        }
      });

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initializing camera: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        errorMessage = 'Camera setup failed: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  void startCapture() {
    if (controller == null || !controller!.value.isInitialized) return;
    startPictureCapture();
  }

  void startPictureCapture() {
    if (captureTimer != null) return;

    captureTimer =
        Timer.periodic( Duration(milliseconds:100~/15), (timer) async {
      if (!isProcessing &&
          mounted &&
          controller != null &&
          controller!.value.isInitialized) {
        isProcessing = true;
        try {
          final XFile image = await controller!.takePicture();
          await _sendImageToServer(
              Uint8List.fromList(await image.readAsBytes()));
        } catch (e) {

          setState(() {
            errorMessage = 'Picture capture error: $e';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          });
        } finally {
          isProcessing = false;
        }
      }
    });
  }

  Future<void> stopCapture() async {
    if (captureTimer != null) {
      captureTimer!.cancel();
      captureTimer = null;
    }
  }

  Future<void> _sendImageToServer(Uint8List imageBytes) async {
    final uri = Uri.parse('http://192.168.1.10:5000/predict');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      contentType: MediaType('image', 'jpeg'),
      filename: 'frame.jpg',
    ));

    try {
      final response = await request.send().timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = jsonDecode(responseData);
        print('Server response: $jsonData'); // Debug output

        if (mounted) {
          setState(() {
            prediction = jsonData['prediction']?.toString() ?? '';
            // sentence = List<String>.from(jsonData['sentence'] ?? []);
            errorMessage = jsonData['error']?.toString() ?? '';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Server communication error: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (controller == null || !controller!.value.isInitialized) return;

    if (state == AppLifecycleState.resumed) {
      initializeCamera();
    } else if (state == AppLifecycleState.paused) {
      stopCapture();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopCapture();
    controller?.dispose();
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
            shape: const CircleBorder(),
            elevation: 3,
            child: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          if (errorMessage.isNotEmpty)
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          FutureBuilder<void>(
            future: initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  controller != null) {
                return Expanded(child: CameraPreview(controller!));
              } else if (snapshot.hasError) {
                return Center(child: Text('Camera error: ${snapshot.error}'));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(15),
              height:160.h ,
              width:375.w ,
              decoration: BoxDecoration(
                color: Colors.black12,
                // border: BorderDirectional(top: BorderSide()),
                borderRadius: BorderRadius.horizontal(right: Radius.circular(25.r),left:Radius.circular(25.r)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 8.h,

                  ),
                  SizedBox(
                    width: 81.w,
                    child: Divider(
                      thickness: 6,
                      color: Colors.white,
                      height: 12.h,
                      radius: BorderRadius.circular(25),
                    ),
                  ),
                  SizedBox(
                    height: 14.h,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(prediction,
                      textAlign: TextAlign.right,
                      style:
                      TextStyle(
                        fontSize:9.sp,
                        color: Theming.primary,
                        fontWeight: FontWeight.w500,
                      ),),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

    );}
}
