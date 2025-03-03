
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final messageId;
  final String text;
  final String sender;
  final  isSeenBy;
  final DateTime timestamp;
  final bool isEdited;
  final String receiver;


  Message(
      {required this.messageId,required this.text, required this.sender, required this.isSeenBy, required this.isEdited, required this.timestamp,required this.receiver});

  Message.fromFireStore(Map<String, Object?> json,String id)
      : this(
    text: json['text'] as String,
    sender: json['sender'] as String,
    isSeenBy: json['isSeenBy'] as bool,
    timestamp: (json['timestamp'] as Timestamp).toDate(),
    isEdited: json['isEdited'] as bool,
    receiver: json['receiver'] as String,
    messageId: id,
  );

  Map<String, Object?> toFireStore() {
    return {
    "text":text,
    'sender': sender,
    'isSeenBy': isSeenBy,
    'timestamp': Timestamp.fromDate(timestamp),
    'isEdited':isEdited,
    'receiver':receiver
  };
}
}