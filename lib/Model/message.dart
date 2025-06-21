
import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  audio,
  video,
  document,
  contact,
}
class MyMessage {
  final String? messageId;
  final String content;
  final String sender;
  final bool isSeenBy;
  final DateTime timestamp;
  final bool isEdited;
  final String receiver;
  final MessageType type;


  MyMessage(
      {required this.type,this.messageId,required this.content, required this.sender, required this.isSeenBy, required this.isEdited, required this.timestamp,required this.receiver});

  MyMessage.fromFireStore(Map<String, dynamic> json,String id)
      : this(
    content: json['content'],
    sender: json['sender'],
    isSeenBy: json['isSeenBy'],
    timestamp: (json['timestamp'] as Timestamp).toDate(),
    isEdited: json['isEdited'],
    receiver: json['receiver'],
    messageId: id,
      type: MessageType.values[json['type']]
  );

  Map<String, Object?> toFireStore() {
    return {
    "content":content,
    'sender': sender,
    'isSeenBy': isSeenBy,
    'timestamp': Timestamp.fromDate(timestamp),
    'isEdited':isEdited,
    'receiver':receiver,
     'type': type.index,
  };
}
}