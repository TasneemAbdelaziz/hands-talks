// import 'dart:convert';
// import 'dart:io';
//
// import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:hands_talks/message/audio_utils/constant.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// class ConvertAudioToText {
//   // static Future<String> covertSpeechToText(String filePath) async{
//   //   const apiKey = SecretApiKey;
//   //   var url = Uri.https("api.openai.com","v1/audio/transcriptions");
//   //   var request = http.MultipartRequest('POST',url);
//   //   request.headers.addAll(({"Authorization":"Bearer $apiKey"}));
//   //   request.fields["model"] = 'whisper-1';
//   //   request.fields["language"]="ar";
//   //   request.files.add(await http.MultipartFile.fromPath('file',filePath));
//   //   var response = await request.send();
//   //   var newrespone = await http.Response.fromStream(response);
//   //   final responeData = json.decode(newrespone.body);
//   //   print(responeData);
//   //   return "123";
//   // }
//
//   // static Future<String> covertSpeechToText(String audioUrl) async {
//   //   const apiKey = SecretApiKey; // Your OpenAI API key
//   //   var url = Uri.https("api.openai.com", "v1/audio/transcriptions");
//   //
//   //   // First download the audio file from Firebase URL
//   //   final audioFile = await _downloadFile(audioUrl);
//   //
//   //   if (audioFile == null) {
//   //     throw Exception("Failed to download audio file");
//   //   }
//   //
//   //   var request = http.MultipartRequest('POST', url);
//   //   request.headers.addAll({"Authorization": "Bearer $apiKey"});
//   //   request.fields["model"] = 'whisper-1';
//   //   request.fields["language"] = "ar";
//   //   request.files.add(await http.MultipartFile.fromPath('file', audioFile.path));
//   //
//   //   try {
//   //     var response = await request.send();
//   //     var newResponse = await http.Response.fromStream(response);
//   //     final responseData = json.decode(newResponse.body);
//   //
//   //     // Clean up: delete the temporary file
//   //     await audioFile.delete();
//   //
//   //     // Return the transcribed text
//   //     print("Transcribed Data ${responseData['text']}");
//   //     return responseData['text'] ?? "No text found";
//   //   } catch (e) {
//   //     await audioFile.delete(); // Clean up even if request fails
//   //     throw Exception("Error in transcription: $e");
//   //   }
//   // }
//   //
//   // static Future<File?> _downloadFile(String url) async {
//   //   try {
//   //     final response = await http.get(Uri.parse(url));
//   //     if (response.statusCode == 200) {
//   //       final directory = await getTemporaryDirectory();
//   //       final file = File('${directory.path}/temp_audio.mp3');
//   //       await file.writeAsBytes(response.bodyBytes);
//   //       return file;
//   //     }
//   //     return null;
//   //   } catch (e) {
//   //     print("Error downloading file: $e");
//   //     return null;
//   //   }
//   // }
//
//   // static Future<String> covertSpeechToText(String audioUrl) async {
//   //   const apiKey = SecretApiKey; // Your OpenAI API key
//   //   var url = Uri.https("api.openai.com", "v1/audio/transcriptions");
//   //
//   //   // 1. First fetch the audio file as bytes from Firebase URL
//   //   final audioResponse = await http.get(Uri.parse(audioUrl));
//   //   if (audioResponse.statusCode != 200) {
//   //     throw Exception('Failed to download audio from Firebase');
//   //   }
//   //
//   //   // 2. Create multipart request for OpenAI
//   //   var request = http.MultipartRequest('POST', url)
//   //     ..headers['Authorization'] = 'Bearer $apiKey'
//   //     ..fields['model'] = 'whisper-1'
//   //     ..fields['language'] = 'ar';
//   //
//   //   // 3. Attach the audio bytes directly without saving to file
//   //   request.files.add(http.MultipartFile.fromBytes(
//   //     'file',
//   //     audioResponse.bodyBytes,
//   //     filename: 'audio.mp3', // Important: Provide a filename
//   //   ));
//   //
//   //   // 4. Send the request
//   //   var response = await request.send();
//   //   var responseBody = await response.stream.bytesToString();
//   //   final responseData = json.decode(responseBody);
//   //
//   //   return responseData['text'] ?? "No transcription available";
//   // }
//
//
//   //  Future<bool> downloadSpeechModel() async {
//   //   try {
//   //     // Download the speech recognition model (English by default)
//   //     await FirebaseModelDownloader.instance.getModel(
//   //       "speech-recognition-ar",
//   //       FirebaseModelDownloadType.latestModel,
//   //       FirebaseModelDownloadConditions(
//   //         iosAllowsCellularAccess: true,
//   //         iosAllowsBackgroundDownloading: false,
//   //         androidChargingRequired: false,
//   //         androidWifiRequired: false,
//   //         androidDeviceIdleRequired: false,
//   //       ),
//   //     );
//   //     return true;
//   //   } catch (e) {
//   //     print("Failed to download model: $e");
//   //     return false;
//   //   }
//   // }
//
//
//
//   Future<File?> _downloadAudioFile(String firebaseUrl) async {
//     try {
//       // Get reference from URL
//       final ref = FirebaseStorage.instance.refFromURL(firebaseUrl);
//
//       // Create temporary file
//       final dir = await getTemporaryDirectory();
//       final file = File('${dir.path}/temp_audio.m4a'); // Keep original format
//
//       // Download
//       await ref.writeToFile(file);
//       return file;
//     } catch (e) {
//       print('Download error: $e');
//       return null;
//     }
//   }
//
//   Future<String?> transcribeStoredAudio(String firebaseUrl) async {
//     // 1. Download file
//     final audioFile = await _downloadAudioFile(firebaseUrl);
//     if (audioFile == null) return null;
//
//     // 2. Initialize recognizer (English)
//     final recognizer = FirebaseVision.instance.speechRecognizer();
//
//     // 3. Process file
//     try {
//       final transcription = await recognizer.processFile(audioFile);
//       await audioFile.delete(); // Clean up
//       return transcription.text;
//     } catch (e) {
//       await audioFile.delete(); // Clean up even if failed
//       print('Transcription error: $e');
//       return null;
//     }
//   }
//
//   // static Future<String?> covertSpeechToText(String audioUrl, BuildContext context) async {
//   // const apiKey = SecretApiKey; // Your OpenAI API key
//   // var url = Uri.https("api.openai.com", "v1/audio/transcriptions");
//   //
//   // try {
//   // // Show loading indicator
//   // showDialog(
//   // context: context,
//   // barrierDismissible: false,
//   // builder: (context) => const Center(child: CircularProgressIndicator()),
//   // );
//   //
//   // // 1. Get audio from Firebase
//   // final audioResponse = await http.get(Uri.parse(audioUrl));
//   // if (audioResponse.statusCode != 200) {
//   // throw Exception('Failed to download audio: ${audioResponse.statusCode}');
//   // }
//   //
//   // // 2. Create request
//   // var request = http.MultipartRequest('POST', url)
//   // ..headers['Authorization'] = 'Bearer $apiKey'
//   // ..fields['model'] = 'whisper-1'
//   // ..fields['language'] = 'ar';
//   //
//   // // 3. Attach audio (convert .m4a to .mp3 filename)
//   // request.files.add(http.MultipartFile.fromBytes(
//   // 'file',
//   // audioResponse.bodyBytes,
//   // filename: 'audio.mp3', // Important: Change extension to .mp3
//   // ));
//   //
//   // // 4. Send request
//   // var response = await request.send();
//   // var responseBody = await response.stream.bytesToString();
//   // final responseData = json.decode(responseBody);
//   //
//   // // Close loading dialog
//   // Navigator.of(context).pop();
//   //
//   // if (responseData['text'] == null) {
//   // throw Exception('No transcription found in response: $responseData');
//   // }
//   //
//   // return responseData['text'];
//   // } catch (e) {
//   // Navigator.of(context).pop(); // Close loading dialog on error
//   // ScaffoldMessenger.of(context).showSnackBar(
//   // SnackBar(content: Text('Error converting audio: ${e.toString()}')),
//   // );
//   // return null;
//   // }
//   // }
//
// }
