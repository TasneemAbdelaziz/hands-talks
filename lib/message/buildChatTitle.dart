import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/Firebase_Utils/Firebase_Auth.dart';
import 'package:hands_talks/Firebase_Utils/firestore_messages.dart';
import 'package:hands_talks/Firebase_Utils/profile_setting.dart';
import 'package:hands_talks/Model/message.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'package:hands_talks/message/Loading_Shimmer/loading_image_chat.dart';
import 'package:hands_talks/theming.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BuildchatTitle extends StatefulWidget {
  MyUser user;
  // String lastMessage;
  // DateTime lastMessageTime;
  // bool isSeen;
  var chatId;


  BuildchatTitle({super.key,required this.chatId,required this.user});

  @override
  State<BuildchatTitle> createState() => _BuildchatTitleState();
}

class _BuildchatTitleState extends State<BuildchatTitle> {
  MyMessage? lastMessage;
@override
  void initState() {

    // TODO: implement initState
    super.initState();
    // _fetchLastMessage();
    print(lastMessage);
  }
  // Stream<void> _fetchLastMessage()  {
  //   print("Fetching last message...");
  //   Message? fetchedMessage =  FirestoreMessages.getLastMessage(widget.chatId);
  //   lastMessage = fetchedMessage;
  // }



  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileSetting>(context, listen: false);

    return StreamBuilder(stream: FirestoreMessages.getLastMessage(widget.chatId), builder: (context,snapshot){
      MyMessage? lastMessage = snapshot.data;
      return ListTile(
        leading:  Padding(
          padding: EdgeInsets.only(right: 0),
          child: FutureBuilder<String?>(
    future: profile
        .getUserImageUrl(widget.user.uId ?? ""),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return LoadingImageChat(); // Optional: Show loading
      }
      final imageUrl = snapshot.data;
      print("IMAGEURL$imageUrl");
      return CircleAvatar(
        backgroundImage: imageUrl != null
            ? NetworkImage(imageUrl)
            : AssetImage("assets/Default_pfp.jpg") as ImageProvider,
      );
    }
    ),

        ),

        title: Text(widget.user.name??"",
          style: Theming.lightTheme.textTheme.titleLarge!.copyWith(
              fontSize: 17),),

        subtitle: StreamBuilder<MyMessage?>(stream:FirestoreMessages.getLastMessage(widget.chatId)

            , builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text("No messages yet", style: TextStyle(color: Colors.grey));
              }
              MyMessage lastMessage = snapshot.data!;
              switch(lastMessage.type){
                case MessageType.text:
                  return Text(
                    lastMessage.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );


                case MessageType.image:
                   return Text("📷 Image");


                case MessageType.audio:
                  return Text("🎵 Audio");


                case MessageType.video:
                  return Text ("📽️ Video");


                case MessageType.document:
                  return Text("📄 Document");


                default:
                  return Text("New message");
              }

            }),


        // Fetch the last message
        // subtitle: Text(
        //   lastMessage, style: Theming.lightTheme.textTheme.bodySmall,),
        trailing: lastMessage != null? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                DateFormat('hh:mm a').format(lastMessage.timestamp), style: Theming.lightTheme.textTheme.bodySmall),
            if (lastMessage.sender == widget.user.phoneNumber && !lastMessage.isSeenBy)...{
              Padding(
                  padding: EdgeInsets.only(left: 10),
                  child:Icon(Icons.circle,color: Colors.green,size: 15,))
            },
          ],
        ):SizedBox(),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
      );
    });
  }
}
