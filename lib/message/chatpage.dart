import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/Firebase_Utils/Firebase_Auth.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'package:hands_talks/message/iconcreation.dart';
import 'package:hands_talks/message/mesage_line.dart';
import 'package:hands_talks/theming.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:hands_talks/Firebase_Utils/firestore_messages.dart';
import 'package:provider/provider.dart';



class ChatPage extends StatefulWidget {

  MyUser user;

   ChatPage({super.key,required this.user});
  static const String routeName = "chatPage";

  @override
  State<ChatPage> createState() => _ChatPageState();
}



class _ChatPageState extends State<ChatPage> {
  User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? chatId;
  String? currentUserPhone;




  File? img;
  final picker = ImagePicker();
  Future getImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if(pickedImage != null){
        img = File(pickedImage.path);
      }
      else{
        print("NO image");
      }
    });
  }

  final record = AudioRecorder();
  String path='';
  String url='';




    void initState() {
      FirebaseAuthService authProvider = Provider.of<FirebaseAuthService>(context, listen: false);
       currentUserPhone = authProvider.myUser?.phoneNumber??"";
      super.initState();

    print("9999999999999999999999999999999999999");
    print("9999999999999999999999999999999999999");


    fetchChatId();
  }
  Future<void> fetchChatId() async {
    String id = await FirestoreMessages.GetOrCreateChatCollection(
        user1Phone:currentUserPhone??"",
       user2Phone: widget.user.phoneNumber??""
    );
    print("-==04-053-0353-450345e0=350=353=-503503-5035");
    print(currentUserPhone);

    setState(() {
      chatId = id;
      
    });
    markMessagesAsSeen();
  }


  void markMessagesAsSeen() {
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
  void _editMessage(BuildContext context, String messageId, String currentText) {
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
                          print("===============================================");
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






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffd9d9d9),
      appBar: AppBar(
        title: Text("Messages",style:Theming.lightTheme.textTheme.titleMedium,),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theming.white,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            color: Theming.white,
            elevation: 0,
            child: ListTile(
                    leading:const CircleAvatar(backgroundColor: Colors.transparent,child: Icon(Icons.account_circle_rounded,size: 50,),
                    ),
                  // ),
                  title: Text(widget.user.name??"",style: Theming.lightTheme.textTheme.titleLarge!.copyWith(fontSize: 17),),
                  subtitle: Text(widget.user.phoneNumber??"",style: Theming.lightTheme.textTheme.bodySmall,),
                  trailing:Image.asset("assets/icons/Videocamera.png",),
                  ),
            ),
          // const Spacer(),
          // Streaming runtime show message
          Expanded(
            child: StreamBuilder<QuerySnapshot>(

              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!.docs;
                print("Number of messages: ${messages.length}");
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    var messageText = message['text'];
                    var messageSender = message['sender'];
                    var messageReciver = message['receiver'];
                    var messageId = message.id;
                    var isEdited = message['isEdited'];
                    var isSeenBy = message['isSeenBy'];
                    // var messageDate = (message['timestamp'] as Timestamp).toDate();
                    bool isMe = messageSender == currentUserPhone;

                    var messageDate;
                    if (message['timestamp'] != null) {
                      messageDate = (message['timestamp'] as Timestamp).toDate();
                    } else {
                      messageDate = DateTime.now(); // Fallback to current time if null
                    }
                    return GestureDetector(
                      onLongPress: (){
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder:(context){
                            if(isMe){
                          return
                            Wrap(
                            children: [
                              ListTile(
                                title: Text("Edit"),
                                leading: Icon(Icons.edit),
                                onTap: (){
                                  Navigator.pop(context);
                                  _editMessage(context, messageId, messageText);
                                  print("-00=-0=0=9430990395039093093093-093-093090395-993-959");
                                  // EditMessage(message: messageText,);
                                  // FirestoreMessages.editMessage(chatId??"", messageId, messageText);
                                }
                              ),
                              ListTile(
                                title: Text("delete for eveyone "),
                                leading: Icon(Icons.delete_forever),
                                onTap: () {
                                  FirestoreMessages.deleteMessageForEveryone(
                                      chatId!, messageId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Message Deleted Successfuly"),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds:1 ),
                                  )
                                  );
                                  Navigator.pop(context);

                                },
                              ),
                            ],
                          );
                        }
                            return Text("null");
                            },);
                      },
                      child: MessageLine(
                        message: messageText,
                        isSeen: isSeenBy,
                        time: messageDate, // Format timestamp
                        isMe: isMe,
                        isEdited:isEdited,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            color: Theming.white,
            height: 100,
            child: Row(
              children: [
                Spacer(),
                InkWell(
                  onTap: (){
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context, builder: (build)=>
                        bottomsheet(),
                    );
                  },
                  child: Icon(Icons.add,size: 40,color: Theming.primary,),
                ),
                Spacer(),
                SizedBox(
                    width: 250,
                    child: TextField(
                      maxLines: 4,
                      minLines: 1,
                      controller: _messageController,
                      decoration: InputDecoration(
                        fillColor: Theming.secondary,
                        filled: true,
                        hintText: "Type a message ...",
                        hintStyle: TextStyle(color: Theming.snackBar),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                Spacer(),
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 25,
                  child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: Theming.icons,
                      ),
                      child: IconButton(
                          icon: Icon(Icons.send,color: Theming.white,size: 25,),
                          onPressed:()async {
                        FirestoreMessages
                            .sendMessage(user:widget.user,sender:currentUserPhone??"" ,text: _messageController.text.trim());
                        _messageController.clear();
                      })),
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );


  }

  Widget bottomsheet(){
    return Container(
      decoration: BoxDecoration(
          color: Theming.white,
        borderRadius: BorderRadius.circular(20)
      ),
      height: 208,

      margin: const EdgeInsets.all(18),

      child: Column(
        children: [
          const Spacer(),
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: open_image_camera,
                child: IconCreation(icon: Icons.camera_alt_rounded, text: "Camera")),
              const Spacer(),
              IconCreation(icon: Icons.mic_rounded, text: "Record",ontab: (){},),
              const Spacer(),
              IconCreation(icon: Icons.person_2_rounded, text: "Contact",ontab: (){},),
              const Spacer(),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              const Spacer(),
              InkWell(
                  onTap:getImage,
                  child: IconCreation(icon: Icons.insert_photo_rounded, text: "Gallery")),
              const Spacer(),
              IconCreation(icon: Icons.location_on_rounded, text: "My Location",ontab: (){},),
              const Spacer(),
              IconCreation(icon: Icons.insert_drive_file_rounded, text: "Document",ontab: (){},),
              const Spacer(),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // start_record()async{
  //   // to get us location for record to recording in it
  //   final location = await getApplicationDocumentsDirectory();
  //   String name = const Uuid().v1();
  //   if(await record.hasPermission()){
  //     await record.start(const RecordConfig(), path: '${location.path}$name.m4a');
  //   }
  //   print("Start Record");
  // }
  stop_record()async{
    String? finalPath = await record.stop();
    setState(() {
      path=finalPath!;
    });
    print("Stop record");
  }
  open_image_gallery()async{
    var get = await ImagePicker().pickImage(source: ImageSource.gallery);

    img=File(get!.path);
    setState(() {

    });
    showAndSend();
  }
  open_image_camera()async{
    var get = await ImagePicker().pickImage(source: ImageSource.camera);
    if (get == null) return;

    img=File(get.path);
    setState(() {
    });
    showAndSend();
  }

  showAndSend(){

    showModalBottomSheet(
      context: context, builder: (build)=> Container(

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Image(image: FileImage(img!,scale: 50)),
          ElevatedButton(onPressed: (){}, child: const Text("Send"))
        ],
      ),
    ),


    );

  }


}
