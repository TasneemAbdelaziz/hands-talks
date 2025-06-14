import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart'as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hands_talks/Firebase_Utils/send_notification_service.dart';
import 'package:hands_talks/Model/message.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'package:hands_talks/message/chatpage.dart';

import 'package:uuid/uuid.dart';

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
      {required MyUser user,required MyMessage message})async {
   var chatId =await GetOrCreateChatCollection(user1Phone: message.sender,user2Phone: user.phoneNumber??"");
try{
  var messageRef = FirebaseFirestore.instance.collection('chats')
      .doc(chatId)
      .collection('messages')
      .doc();





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
  // await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
  //   'lastMessage': text.isNotEmpty?text:"📷 Image",
  //   'lastMessageTime': Timestamp.fromDate(DateTime.now()),
  // });
  String lastMessage;
  switch(message.type){
    case MessageType.text:
      lastMessage = message.content;
      break;

    case MessageType.image:
      lastMessage = "📷 Image";
      break;

    case MessageType.audio:
      lastMessage = "🎵 Audio";
      break;

    case MessageType.video:
      lastMessage = "📽️ Video";
      break;

    case MessageType.document:
      lastMessage = "📄 Document";
      break;
    case MessageType.contact:
      lastMessage = "👤 Contact";

    default:
      lastMessage = "New message";
  }


  sendNotification(
      token: userToken!,
      title: user.name??"",
      body: lastMessage,
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


  static Future<String?>uploadImageToFireStore(File imageFile)async{
    try {
      String fileName = "${DateTime
          .now()
          .microsecondsSinceEpoch}.jpg";
      Reference ref = FirebaseStorage.instance.ref().child(
          "chat_images/$fileName");
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    }catch(e){
      print("ERROR uploading image $e");
      return null;
    }
  }


  static Future<String?> uploadVideoToFireStore(File videoFile) async {
  try {
  String fileName = "${DateTime.now().microsecondsSinceEpoch}.mp4";
  Reference ref = FirebaseStorage.instance.ref().child("chat_videos/$fileName");
  UploadTask uploadTask = ref.putFile(videoFile);
  TaskSnapshot taskSnapshot = await uploadTask;
  return await taskSnapshot.ref.getDownloadURL();
  } catch (e) {
  print("ERROR uploading video: $e");
  return null;
  }
  }



  static Future<String?> uploadDocumentToFireStore(File file) async {
    try {
      String fileName = Uuid().v1();
      Reference ref = FirebaseStorage.instance.ref().child('documents/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading document: $e");
      return null;
    }
  }

  static Future<String> uploadAudioFile(String path) async {
    String name = p.basename(path);
    final ref = FirebaseStorage.instance.ref("voices/$name");

    final metadata = SettableMetadata(contentType: 'audio/m4a');

    await ref.putFile(File(path), metadata);
    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  static Future<void> sendContactToFirebase({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String contactJson,
  }) async {
    final message = MyMessage(
      content: contactJson,
      sender: senderId,
      receiver: receiverId,
      isSeenBy: false,
      isEdited: false,
      timestamp: DateTime.now(),
      type: MessageType.contact,
    );

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toFireStore());
  }



  static Future<void> editMessage(String chatId, String messageId, String newText) async {
   FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').doc(messageId).update(
       {
         'content':newText,
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

  static Stream<MyMessage?> getLastMessage(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1).snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      var data = snapshot.docs.first.data();
      return MyMessage.fromFireStore(data, snapshot.docs.first.id);
    });
  }

}