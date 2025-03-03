import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/Firebase_Utils/firestore_messages.dart';
import 'package:hands_talks/Model/message.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'package:hands_talks/theming.dart';
import 'package:intl/intl.dart';

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
  Message? lastMessage;
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
    return StreamBuilder(stream: FirestoreMessages.getLastMessage(widget.chatId), builder: (context,snapshot){
      Message? lastMessage = snapshot.data;
      return ListTile(
        leading: const Padding(
          padding: EdgeInsets.only(right: 0),
          child: CircleAvatar(backgroundColor: Colors.transparent,
            child: Icon(Icons.account_circle_rounded, size: 50,),
          ),
        ),

        title: Text(widget.user.name??"",
          style: Theming.lightTheme.textTheme.titleLarge!.copyWith(
              fontSize: 17),),

        subtitle: StreamBuilder<Message?>(stream:FirestoreMessages.getLastMessage(widget.chatId)

            , builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text("No messages yet", style: TextStyle(color: Colors.grey));
              }
              Message lastMessage = snapshot.data!;
              return Text(
                lastMessage.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
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
