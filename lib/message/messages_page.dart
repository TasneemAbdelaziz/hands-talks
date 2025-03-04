import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/Authentication/Login/Login_Screen.dart';
import 'package:hands_talks/Firebase_Utils/Firebase_Auth.dart';
import 'package:hands_talks/Model/chat.dart';
import 'package:hands_talks/Model/message.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'package:hands_talks/animation_routing/animation.dart';
import 'package:hands_talks/message/ContactsPage.dart';
import 'package:hands_talks/message/buildChatTitle.dart';
import 'package:hands_talks/message/chatpage.dart';
import 'package:hands_talks/message/custom_search_bar.dart';
import 'package:hands_talks/message/loading_chats.dart';
import 'package:hands_talks/theming.dart';
import 'package:provider/provider.dart';
class MessagesPage extends StatefulWidget {
  static const String routeName = "MessagePage";

  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();

}

class _MessagesPageState extends State<MessagesPage> {
  var authProvider;
  String? currentUserPhone;
  String? name;
  String? uid;
  var chats = [];
  Message? message;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
  }



  // Iterable<Widget> getHistoryList(SearchController controller) {
  //   return chats.map(
  //         (var color) => ListTile(
  //       leading: const Icon(Icons.history),
  //       title: Text(color.label),
  //       trailing: IconButton(
  //         icon: const Icon(Icons.call_missed),
  //         onPressed: () {
  //           controller.text = color.label;
  //           controller.selection = TextSelection.collapsed(
  //             offset: controller.text.length,
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(Duration.zero,()async{
      authProvider = Provider.of<FirebaseAuthService>(context, listen: false);
      await authProvider.getUserProfileInfo();
      setState(() {
        currentUserPhone = authProvider.myUser?.phoneNumber ?? "";
        uid = authProvider.myUser?.uId ?? "";
        name = authProvider.myUser.name ?? "";
      });

      print("???????????????????????????????????");
      print(currentUserPhone);
      print(uid);
      print(name);
      print("???????????????????????????????????");
    });


  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Messages",style: Theming.lightTheme.textTheme.titleLarge,),
        elevation: 0,
        actions: [
          Padding(
            padding:const EdgeInsets.only(right: 10.0) ,
              child: InkWell(
                  onTap: (){
                    Navigator.push(context,
                        CustomAnimation.createRoute(ContactsPage())

                    );

                  },
                  child: Image.asset("assets/icons/Button - Compose.png"))),
        ],
      ),
      body:
         Column(
          children: [
            Expanded(
              child:Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                child: StreamBuilder<QuerySnapshot>(stream: _firestore.collection('chats').where("users",arrayContains:currentUserPhone).orderBy('lastMessageTime',descending: true).snapshots(), builder: (context,snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("");
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("No Chats yet use", style: TextStyle(fontSize: 18, color: Colors.grey)),
                              SizedBox(width: 7,),
                              Image.asset("assets/icons/Button - Compose.png"),
                            ],
                          ),
                           Text("To Start a conversation with your contacts.",style: TextStyle(fontSize: 18, color: Colors.grey),textAlign: TextAlign.center,)
                        ],
                      ),
                    );
                  }


     chats = snapshot.data!.docs.map((doc){
      return Chat.fromFireStore(doc.data() as Map<String,dynamic>, doc.id);}).toList();

                  return ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context,index){
                      var chat = chats[index];
                      String chatID = chat.chatId;
                      print("dgkdlgkjdfglkjdfgljdgldjfg");
                      print(chatID);

                      String recipientPhone = chat.users.firstWhere((phoneNumber) => phoneNumber !=currentUserPhone);
                      return FutureBuilder<QuerySnapshot>(
                        future:_firestore.collection('users').where('phoneNumber', isEqualTo: recipientPhone).get(),
                        builder: (context, snapshot) {

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return LoadingChats();
                          }
                          // if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          //   print("User not found in Firestore: $recipientPhone");
                          //   return ListTile(
                          //     title: Text(recipientPhone),
                          //     subtitle: Text("User not found"),
                          //   );
                          // }
                          // print("Users found: ${snapshot.data!.docs.length}");

                          var userData = snapshot.data!.docs.first.data() as Map<String, dynamic>;

                          MyUser user = MyUser.fromJson(userData);
                          // String recipientName = name ?? recipientPhone;
                          return InkWell(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  CustomAnimation.createRoute(ChatPage(
                                      currentUserPhone:currentUserPhone??"",
                                      recipentPhone: user.phoneNumber??"",
                                      recipentName:user.name??"",
                                  ),)
                                );
                              },

                              child: BuildchatTitle(chatId: chatID,user: user)
                          );
                        },
                      );



                    },


                  );
    }),

              ),
            ),
          ],
        ),

    );
  }
}
