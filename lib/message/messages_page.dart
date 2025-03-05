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
  var searchList = [];
  Message? message;
  bool isSearching = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
  }





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
         Padding(
         padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
      onChanged: (val){
        if(chats.contains(val)){
          searchList.add(val);
        }
      },
        onTap: (){
          setState(() {
            isSearching =true;
          });
        },
        decoration: InputDecoration(
          hintText: "Search By Message...",
          hintStyle: TextStyle(color: Colors.grey[500]),
          filled: true,
          fillColor:Theming.searchbar, // Gray background
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30), // Rounded corners
            borderSide: BorderSide.none, // No border
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon: isSearching?InkWell(
              onTap: (){
                setState(() {
                  isSearching = false;
                });
              },
              child: Icon(Icons.clear,color: Colors.grey[500])):null,
        ),
      ),
    ),
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
                                    user: user,
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
