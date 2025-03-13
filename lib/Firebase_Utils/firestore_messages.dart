import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:hands_talks/Firebase_Utils/send_notification_service.dart';
import 'package:hands_talks/Model/chat.dart';
import 'package:hands_talks/Model/message.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'package:hands_talks/message/chatpage.dart';
import 'package:hands_talks/message/messages_page.dart';

class FirestoreMessages{

  static Future<String> GetOrCreateChatCollection(
      {required String user1Phone, required String user2Phone}) async {
    List<String> users = [user1Phone, user2Phone];
    users.sort();
    String chatId = users.join("_");

    var chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    var chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'users': users,
        'chatId': chatId,
        'lastMessage': "",
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }


  static Future<void> sendMessage(
      {required MyUser user,required String sender,required String text})async {
   var chatId =await GetOrCreateChatCollection(user1Phone: sender,user2Phone: user.phoneNumber??"");
try{
  var messageRef = FirebaseFirestore.instance.collection('chats')
      .doc(chatId)
      .collection('messages')
      .doc();

  Message message = Message(messageId: messageRef.id,
      receiver:user.phoneNumber??"",
      text: text,
      sender: sender,
      isEdited: false,
      timestamp: DateTime.now(),
      // receiver: receiver,
      isSeenBy: false);

  String? userToken;
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uId)
      .get();

  if (userSnapshot.exists) {
    userToken = userSnapshot.get('fcmToken') as String;
    print('User token: $userToken');
  } else {
    print('User not found');
  }



  await messageRef.set(message.toFireStore());
  await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
    'lastMessage': text,
    'lastMessageTime': Timestamp.fromDate(DateTime.now()),
  });
  sendNotification(
      token: userToken!,
      title: user.name??"",
      body: text,
      user:user,
      data: {
        "user": jsonEncode(user.toJson()),
        "route": ChatPage.routeName,
        "id": "120",
      });

}
catch(e){
  print("ERROR $e");
}

  }
 static Future<void> editMessage(String chatId, String messageId, String newText) async {
   FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').doc(messageId).update(
       {
         'text':newText,
         'isEdited':true,
       });
 }

 static Future<void> deleteMessageForEveryone(String chatId, String messageId) async {
   var messageRef = FirebaseFirestore.instance
       .collection('chats')
       .doc(chatId)
       .collection('messages')
       .doc(messageId);

   await messageRef.delete();
 }

  static Stream<Message?> getLastMessage(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1).snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      var data = snapshot.docs.first.data();
      return Message.fromFireStore(data, snapshot.docs.first.id);
    });
  }

}