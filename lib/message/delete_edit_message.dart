import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/Firebase_Utils/firestore_messages.dart';
import 'package:hands_talks/Model/message.dart';
import 'package:hands_talks/message/audio_utils/convert_audio_to_text.dart';
import 'package:hands_talks/message/audio_utils/transcript_screen.dart';
import 'package:hands_talks/message/message_utils.dart';

class DeleteEditMessage extends StatelessWidget {
  String messageId;
  MessageType type;
  var content;
  String chatId;

  DeleteEditMessage(
      {super.key,
      required this.messageId,
      required this.content,
      required this.chatId,
      required this.type});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        if (type == MessageType.text)
          ListTile(
              title: Text("Edit"),
              leading: Icon(Icons.edit),
              onTap: () {
                Navigator.pop(context);
                MessageUtils.editMessage(
                    context: context,
                    messageId: messageId,
                    currentText: content,
                    chatId: chatId);
              }),
        ListTile(
          title: Text("delete for eveyone "),
          leading: Icon(Icons.delete_forever),
          onTap: () {
            FirestoreMessages.deleteMessageForEveryone(chatId, messageId);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Message Deleted Successfuly"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 1),
            ));
            Navigator.pop(context);
          },
        ),
        // if(type == MessageType.audio)ListTile(
        //     title: Text("Convert Audio To Text"),
        //     leading: Image.asset("assets/icons/audioToText.png"),
        //     onTap: () {
        //       print(content);
        //       ConvertAudioToText.covertSpeechToText(content);
        //     }),
        if (type == MessageType.audio)
          ListTile(
            title: Text("Convert Audio To Text"),
            leading: Image.asset("assets/icons/audioToText.png",color: Colors.black,),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TranscribeScreen(audioUrl: content),
                  ));
            },
          ),
      ],
    );
  }
}
