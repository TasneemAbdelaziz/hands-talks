
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat{
  final List<String> users;
  final String chatId;
  final String lastMessage;
  final DateTime lastMessageTime;

  Chat({required this.users,required  this.chatId,required  this.lastMessage,required  this.lastMessageTime});

  // use factory as we need modify
  //  static Chat fromFirestore(Map<String,dynamic> json ,String id){
  //   return Chat(users:List.from(json['users'] ??[]), chatId: id, lastMessage: json['lastMessage'], lastMessageTime: (json['lastMessageTime'] as Timestamp?)?.toDate()??DateTime.now());
  // }

  Chat.fromFireStore(Map<String, dynamic> json,String id)
      : this(
    users: List<String>.from(json['users'] ?? []),
    chatId: id,
    lastMessageTime:(json['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
    lastMessage: json['lastMessage'] as String? ??"",
  );




  Map<String,dynamic> toFireStore(){
    return{
      'users':users,
      'lastMessage':lastMessage,
      'lastMessageTime':lastMessageTime
    };
  }

}