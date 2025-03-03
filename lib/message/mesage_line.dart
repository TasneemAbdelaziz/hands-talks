import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/theming.dart';
import 'package:intl/intl.dart';

class MessageLine extends StatelessWidget {
  String message;
  DateTime time;
  bool isSeen;
  bool isMe;
  bool isEdited;
    MessageLine({super.key,required this.message,required this.isSeen,required this.time,required this.isMe,required this.isEdited});

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, // Align messages
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7, // Limit width
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
    gradient: LinearGradient(
            colors: isMe ? [Color(0xFF10286E), Color(0xFF3F65BE)]: [Colors.white,Colors.white], // Gradient colors
            begin: Alignment.topCenter,  // Gradient starts here
            end: Alignment.bottomCenter, // Gradient ends here
          ),
          // color: isMe ? Colors.blue[200] : Colors.grey[300],
    borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12.0),
                  topRight: const Radius.circular(12.0),
                  bottomRight: isMe?Radius.circular(0):Radius.circular(12.0),
                  bottomLeft: isMe?Radius.circular(12.0):Radius.circular(0)
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              message,
              style: TextStyle(fontSize: 16, color:isMe? Colors.white:Colors.black),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if(isEdited) ...{
                  Text("Edited",style:TextStyle(color:Theming.form,fontSize: 12),),
                },
                SizedBox(width: 10,),
                Text(
                  DateFormat('hh:mm').format(time),
                  style: TextStyle(fontSize: 12, color: isMe? Colors.white:Theming.snackBar),
                ),
                SizedBox(width: 5,),
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
}
