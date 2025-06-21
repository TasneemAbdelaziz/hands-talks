import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hands_talks/Firebase_Utils/firestore_messages.dart';
import 'package:hands_talks/Model/message.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'package:hands_talks/theming.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class VideoHandler {

  static Future<void> openVideoGallery({
    required BuildContext context,
    required String currentUserPhone,
    required MyUser user,
    required Function(bool) setIsUploading,
  }) async {
    final pickedVideo = await ImagePicker().pickVideo(
        source: ImageSource.gallery
    );

    if (pickedVideo != null) {
      _showAndSend(
        context: context,
        videoFile: File(pickedVideo.path),
        currentUserPhone: currentUserPhone,
        user: user,
        setIsUploading: setIsUploading,
      );
    }
  }


  static void _showAndSend({
    required BuildContext context,
    required File videoFile,
    required String currentUserPhone,
    required MyUser user,
    required Function(bool) setIsUploading,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _VideoSendPreview(
        videoFile: videoFile,
        currentUserPhone: currentUserPhone,
        user: user,
        setIsUploading: setIsUploading,
      ),
    );
  }
}


class _VideoSendPreview extends StatefulWidget {
  final File videoFile;
  final String currentUserPhone;
  final MyUser user;
  final Function(bool) setIsUploading;

  const _VideoSendPreview({
    required this.videoFile,
    required this.currentUserPhone,
    required this.user,
    required this.setIsUploading,
  });

  @override
  State<_VideoSendPreview> createState() => _VideoSendPreviewState();
}

class _VideoSendPreviewState extends State<_VideoSendPreview> {
  late VideoPlayerController _controller;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _controller.value.isInitialized
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  GestureDetector(
                    onTap: _togglePlayback,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.black45,
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            )
                : const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 16),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () => _sendVideo(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theming.primary,
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Send",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isUploading ? null : () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _sendVideo(BuildContext context) async {
    setState(() => _isUploading = true);
    widget.setIsUploading(true);

    try {
      final videoUrl = await FirestoreMessages.uploadVideoToFireStore(widget.videoFile);
      if (videoUrl == null) throw Exception("Failed to upload image");

      final message = MyMessage(
        messageId: "",
        receiver: widget.user.phoneNumber ?? "",
        sender: widget.currentUserPhone,
        content: videoUrl,
        isEdited: false,
        timestamp: DateTime.now(),
        type: MessageType.video,
        isSeenBy: false,
      );

      await FirestoreMessages.sendMessage(user: widget.user, message: message);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send image: ${e.toString()}")),
      );
    } finally {
      widget.setIsUploading(false);
      if (mounted) {
        setState(() => _isUploading = false);
        Navigator.pop(context);
      }
    }
  }
}
