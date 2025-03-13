// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_contacts/flutter_contacts.dart';
// import 'package:hands_talks/Firebase_Utils/Firebase_Auth.dart';
// import 'package:hands_talks/animation_routing/animation.dart';
// import 'package:hands_talks/message/chatpage.dart';
// import 'package:provider/provider.dart';
//
// class CustomSearchBar extends StatefulWidget {
//   List<Contact> contacts;
//
//   CustomSearchBar({super.key,required this.contacts});
//
//   @override
//   State<CustomSearchBar> createState() => _CustomSearchBarState();
//
// }
//
// class _CustomSearchBarState extends State<CustomSearchBar> {
//
//
//
//   SearchController searchController = SearchController();
//
// List<Contact> historySearch =[];
//
//   Iterable<Widget> getSuggestions(SearchController controller) {
//
//     final String input = controller.value.text;
//     // currentUserPhone = authProvider.myUser?.phoneNumber ?? "";
//     // authProvider = Provider.of<FirebaseAuthService>(context, listen: false);
//     return widget.contacts
//         .where((contact)=>
//         (contact.displayName.toLowerCase().contains(input) ||
//         contact.phones.any((phone) => phone.number.contains(input)))).take(10)
//         .map(
//           (contact) => ListTile(
//         title: Text(contact.displayName),
//         onTap: () {
//           controller.closeView(contact.displayName);
//           var authProvider = Provider.of<FirebaseAuthService>(context, listen: false);
//           var currentUserPhone = authProvider.myUser?.phoneNumber ?? "";
//           Navigator.push(
//               context,
//               CustomAnimation.createRoute(ChatPage(
//                 currentUserPhone:currentUserPhone,
//                 recipentPhone: contact.phones.first.number,
//                 recipentName:contact.displayName,
//               ),)
//           );
//           handleSelection(contact);
//
//         },
//       ),
//     );
//   }
//
//   void handleSelection(Contact selectedContact) {
//     setState(() {
//       if (historySearch.length >= 5) {
//         historySearch.removeLast();
//       }
//       historySearch.insert(0, selectedContact);
//     });
//   }
//
//
//
//   Iterable<Widget> getHistoryList(SearchController controller) {
//
//
//
//     return historySearch.map(
//           (Contact contact) =>
//               ListTile(
//                 onTap: (){
//                   var authProvider = Provider.of<FirebaseAuthService>(context, listen: false);
//                   var currentUserPhone = authProvider.myUser?.phoneNumber ?? "";
//
//                   Navigator.push(
//                       context,
//                       CustomAnimation.createRoute(ChatPage(
//                         currentUserPhone:currentUserPhone,
//                         recipentPhone: contact.phones.first.number,
//                         recipentName:contact.displayName,
//                       ),)
//                   );
//                 },
//         leading: const Icon(Icons.history),
//         title: Text(contact.displayName),
//         trailing: IconButton(
//           onPressed: (){
//             setState(() {
//               historySearch.remove(contact);
//             });
//           },
//           icon: const Icon(Icons.close)),
//
//         ),
//
//
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return  Padding(
//       padding: EdgeInsets.all(10),
//       child: SearchAnchor(
//         builder: (BuildContext context, SearchController controller) {
//           return IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               controller.openView();
//             },
//           );
//         },
//         isFullScreen: false,
//         suggestionsBuilder: (context,SearchController searchController){
//
//           if(searchController.text.isEmpty){
//             if(historySearch.isNotEmpty){
//               return getHistoryList(searchController);
//             }
//             return <Widget>[
//               const Center(child: Text("No Search History"))
//             ];
//           }
//           return getSuggestions(searchController);
//         },
//
//       ),
//     );
//   }
// }
