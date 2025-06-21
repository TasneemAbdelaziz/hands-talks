import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/Model/message.dart';
import 'package:hands_talks/message/images_utils/full_screen_image_page.dart';
import 'package:hands_talks/message/video_utils/full_screen_video_page.dart';
import 'package:hands_talks/theming.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:voice_note_kit/player/audio_player_widget.dart';
import 'package:voice_note_kit/player/player_enums/player_enums.dart';


class MessageLine extends StatelessWidget {
  String message;
  DateTime time;
  bool isSeen;
  bool isMe;
  bool isEdited;
  MessageType type;
  MessageLine(
      {super.key,
      required this.message,
      required this.isSeen,
      required this.time,
      required this.isMe,
      required this.isEdited,
      required this.type});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft, // Align messages
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7, // Limit width
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isMe
                ? [Color(0xFF10286E), Color(0xFF3F65BE)]
                : [Colors.white, Colors.white], // Gradient colors
            begin: Alignment.topCenter, // Gradient starts here
            end: Alignment.bottomCenter, // Gradient ends here
          ),
          // color: isMe ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12.0),
              topRight: const Radius.circular(12.0),
              bottomRight: isMe ? Radius.circular(0) : Radius.circular(12.0),
              bottomLeft: isMe ? Radius.circular(12.0) : Radius.circular(0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (type == MessageType.image) _buildImageWidget(message),
            if (type == MessageType.audio) _buildAudioWidget(message),
            // if (type == MessageType.document) _buildDocumentWidget(),
            if (type == MessageType.video) _buildVideoWidget(message),
            // if (type == MessageType.contact) _buildContactWidget(message),
            if (type == MessageType.text)
              Text(
                message,
                style: TextStyle(
                    fontSize: 16, color: isMe ? Colors.white : Colors.black),
              ),

            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isEdited) ...{
                  Text(
                    "Edited",
                    style: TextStyle(color: Theming.form, fontSize: 12),
                  ),
                },
                SizedBox(
                  width: 10,
                ),
                Text(
                  DateFormat('hh:mm').format(time),
                  style: TextStyle(
                      fontSize: 12,
                      color: isMe ? Colors.white : Theming.snackBar),
                ),
                SizedBox(
                  width: 5,
                ),
                if (isMe) ...{
                  Icon(
                    Icons.done_all,
                    size: 16,
                    color: isSeen ? Colors.green : Theming.form,
                  ),
                }
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullScreenImagePage(imageUrl: imageUrl),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 250,
            height: 150,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 250,
              height: 150,
              color: Colors.grey[300],
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: 250,
              height: 150,
              color: Colors.grey[300],
              child: _buildErrorWidget()
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoWidget(String videoUrl) {
    return FutureBuilder<String?>(
      future: _generateVideoThumbnail(videoUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return _buildErrorWidget();
        } else {
          return InkWell(
            onTap: () {
              print("Opening FullScreenVideoPage for $videoUrl");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenVideoPage(videoUrl: videoUrl)
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(
                    File(snapshot.data!),
                    width: 250,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: 250,
                    height: 150,
                    color: Colors.black26,
                  ),
                  const Icon(
                    Icons.play_circle_fill,
                    size: 50,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<String?> _generateVideoThumbnail(String videoUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 250,
        quality: 75,
      );
      return thumbnailPath;
    } catch (e) {
      print("Thumbnail generation error: $e");
      return null;
    }
  }

  // Widget _buildVideoWidget(String videoUrl) {
  //   return Builder(
  //     builder: (context) => InkWell(
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (_) => FullScreenVideoPage(videoUrl: videoUrl),
  //           ),
  //         );
  //       },
  //       child: ClipRRect(
  //         borderRadius: BorderRadius.circular(12),
  //         child: Stack(
  //           alignment: Alignment.center,
  //           children: [
  //             Container(
  //               width: 250,
  //               height: 150,
  //               color: Colors.black12,
  //               child: const Icon(
  //                 Icons.videocam,
  //                 color: Colors.grey,
  //                 size: 50,
  //               ),
  //             ),
  //             Container(
  //               width: 250,
  //               height: 150,
  //               color: Colors.black26,
  //             ),
  //             const Icon(
  //               Icons.play_circle_fill,
  //               size: 50,
  //               color: Colors.white,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildAudioWidget(String audioUrl) {
    return AudioPlayerWidget(
      key: UniqueKey(),
      audioType: AudioType.url,
      autoLoad: true,
      audioPath: audioUrl, // Path to the recorded audio file
      size: 60, // Size of the player widget
      progressBarHeight: 7, // Height of the progress bar
      backgroundColor:
      Colors.blueAccent, // Background color of the player
      progressBarColor: Colors.blue, // Color of the progress bar
      progressBarBackgroundColor:
      Colors.white, // Background color of the progress bar
      iconColor: Colors.white, // Color of the play/pause icon
      shapeType: PlayIconShapeType
          .circular, // Shape type for the play/pause icon
      playerStyle:
      PlayerStyle.style1, // Player style for the widget
      // textDirection: TextDirection
      //     .rtl, // Set the text direction (Right to Left)
      width: 300, // Width of the player widget
      showProgressBar: true, // Show the progress bar
      showTimer: true, // Show the timer
    );
  }

  Widget _buildDocumentWidget() {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            final uri = Uri.parse(message);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insert_drive_file, color: Colors.blue),
              SizedBox(width: 8),
              Text("Open Document", style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        Text(DateFormat('hh:mm a').format(time),
            style: TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildContactWidget(String contactJson) {
    Map<String, dynamic> contactData;
    try {
      contactData = jsonDecode(Uri.decodeComponent(contactJson));
    } catch (e) {
      contactData = {"name": "Unknown", "phone": "N/A"};
    }

    final name = contactData['name'] ?? 'Unknown';
    final phone = contactData['phone'] ?? 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(child: Icon(Icons.contact_phone)),
          title: Text(name,
              style: TextStyle(color: isMe ? Colors.white : Colors.black)),
          subtitle: Text(phone,
              style: TextStyle(color: isMe ? Colors.white70 : Colors.black87)),
          trailing: IconButton(
            icon:
                Icon(Icons.call, color: isMe ? Colors.white : Theming.primary),
            onPressed: () async {
              final uri = Uri.parse("tel:$phone");
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() => Container(
    width: 250,
    height: 150,
    color: Colors.grey[300],
    child: const Center(
      child: Icon(Icons.error, color: Colors.red),
    ),
  );

}
