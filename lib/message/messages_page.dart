// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:hands_talks/Firebase_Utils/Firebase_Auth.dart';
// import 'package:hands_talks/Model/chat.dart';
// import 'package:hands_talks/Model/message.dart';
// import 'package:hands_talks/Model/myUser.dart';
// import 'package:hands_talks/animation_routing/animation.dart';
// import 'package:hands_talks/message/ContactsPage.dart';
// import 'package:hands_talks/message/buildChatTitle.dart';
// import 'package:hands_talks/message/chatpage.dart';
// import 'package:hands_talks/message/Loading_Shimmer/loading_chats.dart';
// import 'package:hands_talks/theming.dart';
// import 'package:provider/provider.dart';
// class MessagesPage extends StatefulWidget {
//   static const String routeName = "MessagePage";
//
//   const MessagesPage({super.key});
//
//   @override
//   State<MessagesPage> createState() => _MessagesPageState();
//
// }
//
// class _MessagesPageState extends State<MessagesPage> {
//   var authProvider;
//   String? currentUserPhone;
//   String? name;
//   String? uid;
//   var chats = [];
//   var searchList = [];
//   MyMessage? message;
//   bool isSearching = false;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     Future.delayed(Duration.zero,()async{
//       authProvider = Provider.of<FirebaseAuthService>(context, listen: false);
//       // await authProvider.getUserProfileInfo();
//       setState(() {
//         currentUserPhone = authProvider.myUser?.phoneNumber ?? "";
//         uid = authProvider.myUser?.uId ?? "";
//         name = authProvider.myUser.name ?? "";
//       });
//
//     });
//
//
//   }
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text("Messages",style: Theming.lightTheme.textTheme.titleLarge,),
//         elevation: 0,
//         actions: [
//           Padding(
//             padding:const EdgeInsets.only(right: 10.0) ,
//               child: InkWell(
//                   onTap: (){
//                     Navigator.push(context,
//                         CustomAnimation.createRoute(ContactsPage())
//                     );
//                   },
//                   child: Image.asset("assets/icons/Button - Compose.png"))),
//         ],
//       ),
//       body:
//          Column(
//           children: [
//     //      Padding(
//     //      padding: const EdgeInsets.symmetric(horizontal: 16.0),
//     //   child: TextField(
//     //   onChanged: (val){
//     //     if(chats.contains(val)){
//     //       searchList.add(val);
//     //     }
//     //   },
//     //     onTap: (){
//     //       setState(() {
//     //         isSearching =true;
//     //       });
//     //     },
//     //     decoration: InputDecoration(
//     //       hintText: "Search By Message...",
//     //       hintStyle: TextStyle(color: Colors.grey[500]),
//     //       filled: true,
//     //       fillColor:Theming.searchbar, // Gray background
//     //       contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//     //       border: OutlineInputBorder(
//     //         borderRadius: BorderRadius.circular(30), // Rounded corners
//     //         borderSide: BorderSide.none, // No border
//     //       ),
//     //       prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
//     //       suffixIcon: isSearching?InkWell(
//     //           onTap: (){
//     //             setState(() {
//     //               isSearching = false;
//     //             });
//     //           },
//     //           child: Icon(Icons.clear,color: Colors.grey[500])):null,
//     //     ),
//     //   ),
//     // ),
//             Expanded(
//               child:Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
//                 child: StreamBuilder<QuerySnapshot>(stream: _firestore.collection('chats').where("users",arrayContains:currentUserPhone).orderBy('lastMessageTime',descending: true).snapshots(), builder: (context,snapshot){
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Text("");
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text("No Chats yet use", style: TextStyle(fontSize: 18, color: Colors.grey)),
//                               SizedBox(width: 7,),
//                               Image.asset("assets/icons/Button - Compose.png"),
//                             ],
//                           ),
//                            Text("To Start a conversation with your contacts.",style: TextStyle(fontSize: 18, color: Colors.grey),textAlign: TextAlign.center,)
//                         ],
//                       ),
//                     );
//                   }
//      chats = snapshot.data!.docs.map((doc){
//       return Chat.fromFireStore(doc.data() as Map<String,dynamic>, doc.id);}).toList();
//
//                   return ListView.builder(
//                     itemCount: chats.length,
//                     itemBuilder: (context,index){
//                       var chat = chats[index];
//                       String chatID = chat.chatId;
//
//                       String recipientPhone = chat.users.firstWhere((phoneNumber) => phoneNumber !=currentUserPhone);
//                       return FutureBuilder<QuerySnapshot>(
//                         future:_firestore.collection('users').where('phoneNumber', isEqualTo: recipientPhone).get(),
//                         builder: (context, snapshot) {
//
//                           if (snapshot.connectionState == ConnectionState.waiting) {
//                             return LoadingChats();
//                           }
//                           var userData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
//
//                           MyUser user = MyUser.fromJson(userData);
//                           // String recipientName = name ?? recipientPhone;
//                           return InkWell(
//                               onTap: (){
//                                 Navigator.push(
//                                   context,
//                                   CustomAnimation.createRoute(ChatPage(
//                                     user: user,
//                                   ),)
//                                 );
//                               },
//
//                               child: BuildchatTitle(chatId: chatID,user: user)
//                           );
//                         },
//                       );
//                     },
//                   );
//     }),
//               ),
//             ),
//           ],
//         ),
//
//     );
//   }
// }





















import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/Firebase_Utils/Firebase_Auth.dart';
import 'package:hands_talks/Model/chat.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'package:hands_talks/animation_routing/animation.dart';
import 'package:hands_talks/message/ContactsPage.dart';
import 'package:hands_talks/message/buildChatTitle.dart';
import 'package:hands_talks/message/chatpage.dart';
import 'package:hands_talks/message/Loading_Shimmer/loading_chats.dart';
import 'package:hands_talks/theming.dart';
import 'package:provider/provider.dart';

class MessagesPage extends StatefulWidget {
  static const String routeName = "MessagePage";

  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late FirebaseAuthService _authProvider;
  String? _currentUserPhone;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _authProvider = Provider.of<FirebaseAuthService>(context, listen: false);
    await _authProvider.getUserProfileInfo();
    setState(() {
      _currentUserPhone = _authProvider.myUser?.phoneNumber ?? "";
      _isLoading = false;
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("No chats yet - use ", style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(width: 7),
              Image.asset("assets/icons/Button - Compose.png"),
            ],
          ),
          Text(
            "To start a conversation with your contacts.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chats')
          .where("users", arrayContains: _currentUserPhone)
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingChats();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final chats = snapshot.data!.docs.map((doc) {
          return Chat.fromFireStore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            final recipientPhone = chat.users.firstWhere(
                  (phoneNumber) => phoneNumber != _currentUserPhone,
              orElse: () => "",
            );

            if (recipientPhone.isEmpty) return const SizedBox();

            return FutureBuilder<QuerySnapshot>(
              future: _firestore.collection('users').where('phoneNumber', isEqualTo: recipientPhone).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingChats();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox();
                }

                final userData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                final user = MyUser.fromJson(userData);

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      CustomAnimation.createRoute(ChatPage(user: user)),
                    );
                  },
                  child: BuildchatTitle(chatId: chat.chatId, user: user),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Messages", style: Theming.lightTheme.textTheme.titleLarge),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  CustomAnimation.createRoute(ContactsPage()),
                );
              },
              child: Image.asset("assets/icons/Button - Compose.png"),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: _buildChatList(),
      ),
    );
  }
}