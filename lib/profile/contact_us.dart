import 'package:flutter/material.dart';
import 'package:hands_talks/Firebase_Utils/Firebase_Auth.dart';
import 'package:hands_talks/theming.dart';
import 'package:provider/provider.dart';

import '../Firebase_Utils/profile_setting.dart';

class ContactUsPage extends StatefulWidget {
  static const String routeName = "ContactUsScreen";

  const ContactUsPage({super.key});

  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  late var authProvider;
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    authProvider=Provider.of<FirebaseAuthService>(context, listen: false);
   var profileProvider=Provider.of<ProfileSetting>(context, listen: false);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Contact Us",
          style: TextStyle(
            color: Theming.primary,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
          
              // Name Field
              TextFormField(
                controller: TextEditingController( text:authProvider.myUser?.name??""),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  labelStyle: TextStyle(color: Theming.primary),
                  filled: true,
                  fillColor: Theming.form,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
          
              // Email Field
              TextFormField(
                readOnly: true,
                controller: TextEditingController(text:authProvider.myUser?.email??""),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: Theming.primary),
                  filled: true,
                  fillColor: Theming.form,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
          
              // Message Field
              TextFormField(
                validator: (value) {
                  if(value==null || value.isEmpty){
                    return "Please enter your message";
                  }
                  return null;
                },
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: "Your Message",
                  labelStyle: TextStyle(color: Theming.primary),
                  filled: true,
                  fillColor: Theming.form,
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24),
          
              // Submit Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Theming.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Handle the contact form submission
                    if (formKey.currentState!.validate()) {
                      profileProvider.addReports(name: authProvider.myUser?.name??"", email: authProvider.myUser?.email??"", message: _messageController.text);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Thank you for contacting us!"),
                        backgroundColor: Theming.primary,
                      )
                    );
                    Navigator.pop(context);
                  }},
                  child: Text(
                    "SEND MESSAGE",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theming.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
