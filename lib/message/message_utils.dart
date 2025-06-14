import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/Model/message.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'package:hands_talks/Firebase_Utils/firestore_messages.dart';
import 'package:hands_talks/theming.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MessageUtils {

  static void markMessagesAsSeen({required String chatId, required String currentUserPhone}) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiver', isEqualTo: currentUserPhone)
        .where('isSeenBy', isEqualTo: false) // Fetch only unseen messages
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'isSeenBy': true});
      }
    });
  }


  // Edit Message
  static void editMessage(
      {required BuildContext context,
      required String messageId,
      required String currentText,
      required String chatId}) {
    TextEditingController editController = TextEditingController(text: currentText);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to expand fully
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  maxLines: 4,
                  minLines: 1,
                  controller: editController,
                  decoration: InputDecoration(
                    fillColor: Theming.secondary,
                    filled: true,
                    hintText: "Edit message...",
                    hintStyle: TextStyle(color: Theming.snackBar),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close bottom sheet
                      },
                      child: Text("Cancel"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theming.primary,
                      ),
                      onPressed: () {
                        String updatedMessage = editController.text.trim();
                        if (updatedMessage.isNotEmpty) {
                          print("Updated Message: $updatedMessage");
                          FirestoreMessages.editMessage(chatId!, messageId, editController.text.trim());
                          Navigator.pop(context); // Close bottom sheet after saving
                        }
                      },
                      child: Text("Save",style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}