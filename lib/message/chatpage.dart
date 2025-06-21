import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/Firebase_Utils/Firebase_Auth.dart';
import 'package:hands_talks/Firebase_Utils/profile_setting.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'package:hands_talks/message/audio_utils/record_handel.dart';
import 'package:hands_talks/message/delete_edit_message.dart';
import 'package:hands_talks/message/icon_creation.dart';
import 'package:hands_talks/message/images_utils/image_functions.dart';
import 'package:hands_talks/message/mesage_line.dart';
import 'package:hands_talks/message/message_utils.dart';
import 'package:hands_talks/message/video_utils/video_handler.dart';
import 'package:hands_talks/theming.dart';
import 'package:record/record.dart';
import 'package:hands_talks/Firebase_Utils/firestore_messages.dart';
import 'package:provider/provider.dart';
import 'package:hands_talks/Model/message.dart';

import 'Loading_Shimmer/loading_image_chat.dart';
// import 'package:zego_uikit/zego_uikit.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';


class ChatPage extends StatefulWidget {
  MyUser user;

  ChatPage({super.key, required this.user});
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
  // var pickedImage;
  // final record = AudioRecorder();
  bool isUploading = false;

  void initState() {
    FirebaseAuthService authProvider =
    Provider.of<FirebaseAuthService>(context, listen: false);
    currentUserPhone = authProvider.myUser?.phoneNumber ?? "";

    super.initState();
    fetchChatId();
  }

  Future<void> fetchChatId() async {
    String id = await FirestoreMessages.GetOrCreateChatCollection(
        user1Phone: currentUserPhone ?? "",
        user2Phone: widget.user.phoneNumber ?? "");
    print(currentUserPhone);
    setState(() {
      chatId = id;
    });
    MessageUtils.markMessagesAsSeen(
        chatId: chatId!, currentUserPhone: currentUserPhone!);
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileSetting>(context);
    return Scaffold(
      backgroundColor: const Color(0xffd9d9d9),
      appBar: AppBar(
        title: Text(
          "Messages",
          style: Theming.lightTheme.textTheme.titleMedium,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theming.white,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(0),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            color: Theming.white,
            elevation: 0,
            child: ListTile(
              leading: FutureBuilder<String?>(
            future: Provider.of<ProfileSetting>(context, listen: false)
                .getUserImageUrl(widget.user.uId ?? "" ),
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
      },
    ),
              // title: Text(
              //   widget.user.name ?? "",
              //   style: Theming.lightTheme.textTheme.titleLarge!
              //       .copyWith(fontSize: 17),
              // ),
              // subtitle: Text(
              //   widget.user.phoneNumber ?? "",
              //   style: Theming.lightTheme.textTheme.bodySmall,
              // ),
              // trailing: Image.asset(
              //   "assets/icons/Videocamera.png",
              // ),
              // ),

              title: Text(
                widget.user.name ?? "",
                style: Theming.lightTheme.textTheme.titleLarge!
                    .copyWith(fontSize: 17),
              ),
              subtitle: Text(
                widget.user.phoneNumber ?? "",
                style: Theming.lightTheme.textTheme.bodySmall,
              ),
              // trailing: ZegoSendCallInvitationButton(
              //   iconSize: Size(40, 40),
              //   buttonSize: Size(50, 50),
              //   isVideoCall: true,
              //   resourceID: "HandsTalks",
              //   invitees: [
              //     ZegoUIKitUser(
              //       id: widget.user.uId ?? "", // must match login id
              //       name: widget.user.name ?? "",
              //     ),
              //   ],
              // ),
            ),
          ),
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
                    var content = message['content'];
                    var messageSender = message['sender'];
                    var messageId = message.id;
                    var isEdited = message['isEdited'];
                    var isSeenBy = message['isSeenBy'];
                    bool isMe = messageSender == currentUserPhone;

                    var messageDate;
                    if (message['timestamp'] != null) {
                      messageDate =
                          (message['timestamp'] as Timestamp).toDate();
                    } else {
                      messageDate =
                          DateTime.now(); // Fallback to current time if null
                    }
                    return GestureDetector(
                      onLongPress: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            if (isMe) {
                              return DeleteEditMessage(messageId: messageId, content: content, chatId: chatId??"",type: MessageType.values[message['type']]);
                            }
                            return SizedBox();
                          },
                        );
                      },
                      child: MessageLine(
                          message: content,
                          isSeen: isSeenBy,
                          time: messageDate,
                          // Format timestamp
                          isMe: isMe,
                          isEdited: isEdited,
                          type: MessageType.values[message['type']]),
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
                  onTap: () {
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (build) => bottomsheet(),
                    );
                  },
                  child: Icon(
                    Icons.add,
                    size: 40,
                    color: Theming.primary,
                  ),
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
                          icon: Icon(
                            Icons.send,
                            color: Theming.white,
                            size: 25,
                          ),
                          onPressed: () async {
                            MyMessage textMessage = MyMessage(
                              messageId: "",
                              // Will be assigned in sendMessage
                              receiver: widget.user.phoneNumber ?? "",
                              content: _messageController
                                  .text,
                              // The text from the input field
                              sender: currentUserPhone ?? "",
                              isEdited: false,
                              timestamp: DateTime.now(),
                              type: MessageType.text,
                              isSeenBy: false,
                            );
                            FirestoreMessages.sendMessage(
                                user: widget.user, message: textMessage);
                            _messageController.clear();
                          },
                          ),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );


  }

  Widget bottomsheet() {
    return Container(
      decoration: BoxDecoration(
          color: Theming.white, borderRadius: BorderRadius.circular(20)),
      height: 208,
      margin: const EdgeInsets.all(18),
      child: Column(
        children: [
          const Spacer(),
          Row(

            children: [
              const Spacer(),
              IconCreation(
                icon: Icons.camera_alt_rounded,
                text: "Camera",
                ontab: () =>
                    ImageHandler.openImageCamera(
                      context: context,
                      currentUserPhone: currentUserPhone ?? "",
                      user: widget.user,
                      setIsUploading: (value) =>
                          setState(() => isUploading = value),
                    ),
              ),
              const Spacer(),
              IconCreation(
                  icon: Icons.mic_rounded,
                  text: "Voice",
                  ontab: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context)=>
                      Container(
                          width: double.infinity,
                          height:  MediaQuery.of(context).size.height * 0.3,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                              Center(child:
                              RecordHandel(user: widget.user)
                              ),
                              Text("Long Press to Record")
                            ],
                          ))
                    );
                  }),
              // ---------------------
              // const Spacer(),
              // IconCreation(
              //   icon: Icons.person_2_rounded,
              //   text: "Contact",
              //   ontab: () async {
              //     final List<Contact>? selectedContacts = await Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (_) => SendContactPage()),
              //     );
              //
              //     if (selectedContacts == null || selectedContacts.isEmpty)
              //       return;
              //
              //     if (chatId == null) {
              //       // من الأفضل التعامل مع الحالة دي، مثلا عرض رسالة خطأ
              //       return;
              //     }
              //
              //     for (final contact in selectedContacts) {
              //       if (contact.phones.isEmpty) continue;
              //
              //       String contactJson = jsonEncode({
              //         'name': contact.displayName,
              //         'phone': contact.phones.first.number,
              //       });
              //
              //       await FirestoreMessages.sendContactToFirebase(
              //         chatId: chatId!,
              //         contactJson: contactJson,
              //         senderId: currentUserPhone ?? "",
              //         receiverId: widget.user.phoneNumber ?? "",
              //       );
              //     }
              //   },
              // ),

              const Spacer(),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              const Spacer(),
              IconCreation(
                icon: Icons.insert_photo_rounded,
                text: "Gallery",
                ontab: () =>
                    ImageHandler.openImageGallery(
                      context: context,
                      currentUserPhone: currentUserPhone ?? "",
                      user: widget.user,
                      setIsUploading: (value) =>
                          setState(() => isUploading = value),
                    ),
              ),
              const Spacer(),
              IconCreation(
                icon: Icons.videocam_rounded,
                text: "Video",
                ontab: () =>VideoHandler.openVideoGallery(
                  context: context,
                  currentUserPhone: currentUserPhone ?? "",
                  user: widget.user,
                  setIsUploading: (value) =>
                      setState(() => isUploading = value),
                ),
              ),
              // const Spacer(),
              // IconCreation(
              //   icon: Icons.insert_drive_file_rounded,
              //   text: "Document",
              //   ontab: () async {
              //     Navigator.pop(context);
              //     FilePickerResult? result = await FilePicker.platform
              //         .pickFiles(
              //         type: FileType.custom,
              //         allowedExtensions: ['pdf', 'doc', 'docx', 'txt']);
              //     if (result != null && result.files.single.path != null) {
              //       File file = File(result.files.single.path!);
              //       String? downloadUrl =
              //       await FirestoreMessages.uploadDocumentToFireStore(file);
              //
              //       if (downloadUrl != null) {
              //         MyMessage docMessage = MyMessage(
              //           messageId: "",
              //           receiver: widget.user.phoneNumber ?? "",
              //           content: downloadUrl,
              //           sender: currentUserPhone ?? "",
              //           isEdited: false,
              //           timestamp: DateTime.now(),
              //           type: MessageType.document,
              //           isSeenBy: false,
              //         );
              //         FirestoreMessages.sendMessage(
              //             user: widget.user, message: docMessage);
              //       } else {
              //         ScaffoldMessenger.of(context).showSnackBar(
              //           SnackBar(content: Text("Failed to upload document")),
              //         );
              //       }
              //     }
              //   },
              // ),
              const Spacer(),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

}