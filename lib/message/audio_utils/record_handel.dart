import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/Firebase_Utils/Firebase_Auth.dart';
import 'package:hands_talks/Firebase_Utils/firestore_messages.dart';
import 'package:hands_talks/Model/message.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:voice_note_kit/player/utils/audio_player_controller.dart';
import 'package:voice_note_kit/recorder/voice_recorder_widget.dart';

class RecordHandel extends StatefulWidget {
   RecordHandel({super.key,required this.user});

  MyUser user;
  @override
  State<RecordHandel> createState() => _RecordHandelState();
}

class _RecordHandelState extends State<RecordHandel> {
  File? recordedFile; // Variable to hold the recorded audio file locally
  final record = AudioRecorder();
  String recordedAudioBlobUrl =
      ""; // Variable to hold the recorded audio blob URL
  String? currentUserPhone;
  late final VoiceNotePlayerController playerController;

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    FirebaseAuthService authProvider =
    Provider.of<FirebaseAuthService>(context, listen: false);
    currentUserPhone = authProvider.myUser?.phoneNumber ?? "";
    playerController = VoiceNotePlayerController();

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  VoiceRecorderWidget(
      iconSize: 100,
      // Size of the recording icon
      showTimerText: true,
      // Show the recording timer
      showSwipeLeftToCancel:
      true,
      // Allow swipe left to cancel the recording
      /////==============================================================
      // When recording is finished, save the file and display its path
      onRecorded: (file) async {
        setState(() {
          recordedFile = file; // Store the recorded file
          print("ENDDD record");
        });
        // Directory appDocDir = await getApplicationDocumentsDirectory();
        // String localPath = '${appDocDir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
        //
        // // نسخ الملف المؤقت إلى المسار الدائم
        // await file.copy(localPath);
        //
        // print("File saved locally at $localPath");

        try {
          String? audioUrl =
          await FirestoreMessages.uploadAudioFile(
              recordedFile!.path);
          print("Audio URL: $audioUrl"); // هنا بتطبع الرابط في الـ console

          MyMessage audioMessage = MyMessage(
            messageId: "",
            receiver: widget.user.phoneNumber ?? "",
            content: audioUrl ?? "",
            sender: currentUserPhone ?? "",
            isEdited: false,
            timestamp: DateTime.now(),
            type: MessageType.audio,
            isSeenBy: false,
          );
          print(audioMessage);
          FirestoreMessages.sendMessage(
              user: widget.user, message: audioMessage);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to send audio")),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Recording saved: ${file
                      .path}')), // Display the recorded file's path
        );
      },
      // When error occurs during recording
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error: $error')), // Display any errors during recording
        );
      },

      // If recording was cancelled
      actionWhenCancel: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Recording Cancelled')), // Notify the user that the recording was cancelled
        );
      },
      permissionNotGrantedMessage:
      'Microphone permission required',
      // Message when permission is not granted
      dragToLeftText:
      'Swipe left to cancel recording',
      // Text for drag-to-left action
      dragToLeftTextStyle: const TextStyle(
        color: Colors.blueAccent,
        fontSize: 18,
      ),
      cancelDoneText:
      'Recording cancelled',
      // Text displayed when recording is cancelled
      backgroundColor: Colors
          .blueAccent,
      // Background color of the recorder widget
      cancelHintColor: Colors.red,
      // Color of the cancel hint
      iconColor: Colors.white,
      // Color of the record icon
      timerFontSize: 18, // Font size of the timer
    );
  }
}
