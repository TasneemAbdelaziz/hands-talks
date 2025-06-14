import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hands_talks/Firebase_Utils/firestore_messages.dart';
import 'package:hands_talks/Model/message.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'package:hands_talks/theming.dart';
import 'package:image_picker/image_picker.dart';

class ImageHandler {
  static Future<void> openImageGallery({
    required BuildContext context,
    required String currentUserPhone,
    required MyUser user,
    required Function(bool) setIsUploading,
  }) async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedImage != null) {
      _showAndSend(
        context: context,
        imageFile: File(pickedImage.path),
        currentUserPhone: currentUserPhone,
        user: user,
        setIsUploading: setIsUploading,
      );
    }
  }

  static Future<void> openImageCamera({
    required BuildContext context,
    required String currentUserPhone,
    required MyUser user,
    required Function(bool) setIsUploading,
  }) async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (pickedImage != null) {
      _showAndSend(
        context: context,
        imageFile: File(pickedImage.path),
        currentUserPhone: currentUserPhone,
        user: user,
        setIsUploading: setIsUploading,
      );
    }
  }

  static void _showAndSend({
    required BuildContext context,
    required File imageFile,
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
      builder: (context) => _ImageSendPreview(
        imageFile: imageFile,
        currentUserPhone: currentUserPhone,
        user: user,
        setIsUploading: setIsUploading,
      ),
    );
  }
}

class _ImageSendPreview extends StatefulWidget {
  final File imageFile;
  final String currentUserPhone;
  final MyUser user;
  final Function(bool) setIsUploading;

  const _ImageSendPreview({
    required this.imageFile,
    required this.currentUserPhone,
    required this.user,
    required this.setIsUploading,
  });

  @override
  State<_ImageSendPreview> createState() => _ImageSendPreviewState();
}

class _ImageSendPreviewState extends State<_ImageSendPreview> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              widget.imageFile,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),

          _isUploading
              ? const CircularProgressIndicator()
              : ElevatedButton(
            onPressed: () => _sendImage(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theming.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
    );
  }

  Future<void> _sendImage(BuildContext context) async {
    setState(() => _isUploading = true);
    widget.setIsUploading(true);

    try {
      final imageUrl = await FirestoreMessages.uploadImageToFireStore(widget.imageFile);
      if (imageUrl == null) throw Exception("Failed to upload image");

      final message = MyMessage(
        messageId: "",
        receiver: widget.user.phoneNumber ?? "",
        sender: widget.currentUserPhone,
        content: imageUrl,
        isEdited: false,
        timestamp: DateTime.now(),
        type: MessageType.image,
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
