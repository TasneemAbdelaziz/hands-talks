import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:hands_talks/Firebase_Utils/Firebase_Auth.dart';
import 'package:hands_talks/message/chatpage.dart';
import 'package:hands_talks/message/custom_search_bar.dart';
import 'package:hands_talks/theming.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsPage extends StatefulWidget {
  static const String routeName = "ContactsPage";

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final SearchController searchController = SearchController();
  late FirebaseAuthService authProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Contact> contacts = [];
  Set<String> appUsers = {}; // Store Firebase users for fast lookup


  final List<Contact> searchList = [];
  bool isSearching = false;
  String currentUserPhone = "";
  String uid ="";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Future.delayed(Duration.zero,()async{
      authProvider = Provider.of<FirebaseAuthService>(context, listen: false);
      await authProvider.getUserProfileInfo();
      setState(() {
        currentUserPhone = authProvider.myUser?.phoneNumber ?? "";
        uid = authProvider.myUser?.uId ?? "";
      });
      fetchAppUsers();
    });
  }

  Future<void> fetchAppUsers() async {
    QuerySnapshot usersSnapshot = await _firestore.collection('users').get();

    Set<String> firebaseUsers = usersSnapshot.docs
        .map((doc) => doc['phoneNumber'] as String)
        .toSet();

    setState(() => appUsers = firebaseUsers);
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    var status = await Permission.contacts.request();
    if (status.isGranted) {
      List<Contact> phoneContacts =
      await FlutterContacts.getContacts(withProperties: true);

      phoneContacts.removeWhere((contact) =>
      contact.phones.isNotEmpty &&
          contact.phones.first.number == currentUserPhone);

      phoneContacts.sort((a, b) {
        bool isAAppUser = appUsers.contains(a.phones.isNotEmpty ? a.phones.first.number : "");
        bool isBAppUser = appUsers.contains(b.phones.isNotEmpty ? b.phones.first.number : "");

        if (isAAppUser && !isBAppUser) return -1;
        if (!isAAppUser && isBAppUser) return 1;
        return 0;
      });

      setState(() => contacts = phoneContacts);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Permission denied. Enable in settings.")));
    }
  }

  // Send an invite via SMS
  void sendInvite(String phoneNumber) async {
    final message = Uri.encodeComponent("Hey! Try this amazing app: [Hands Talk]");
    final uri = Uri.parse("sms:$phoneNumber?body=$message");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Could not open SMS")));
    }
  }



  @override
  Widget build(BuildContext context) {
     // authProvider = Provider.of<FirebaseAuthService>(context);
    return Scaffold(
      appBar: AppBar(
          actions: [
            CustomSearchBar(contacts: contacts)

          ],
          title: Text("Select Contacts")),
      body: contacts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          final phoneNumber =
          contact.phones.isNotEmpty ? contact.phones.first.number : "";

          bool isAppUser = appUsers.contains(phoneNumber);

          return ListTile(
            leading: CircleAvatar(child: Text(contact.displayName.isNotEmpty?contact.displayName[0]:"?")),
            title: Text(contact.displayName),
            subtitle: Text(phoneNumber),
            trailing: isAppUser
                ? IconButton(
              onPressed: () {
                print("00000000000000000000000000");
                print(currentUserPhone);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      currentUserPhone:currentUserPhone,
                      recipentPhone: phoneNumber,
                      recipentName: contact.displayName,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.send),
              color: Theming.primary,
            )
                : ElevatedButton(
              onPressed: () => sendInvite(phoneNumber),
              child: Text("Invite"),
            ),
          );
        },
      ),
    );
  }
}
