import 'package:flutter/material.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'package:hands_talks/theming.dart';
import 'package:provider/provider.dart';

import '../Firebase_Utils/Firebase_Auth.dart';

class EditInformationPage extends StatefulWidget {
  static const String routeName = "EditInformationScreen";

  const EditInformationPage({super.key});

  @override
  _EditInformationPageState createState() => _EditInformationPageState();
}

class _EditInformationPageState extends State<EditInformationPage> {
  // Controllers for text fields
   TextEditingController _nameController = TextEditingController();
  String _selectedCountry = "Egypt"; // Default country

  final List<String> _countries = ["Egypt"];
// late var args;
   late var authProvider=Provider.of<FirebaseAuthService>(context, listen: false);
  @override
  void initState() {

    super.initState();
    // Pre-fill fields with example data
    _nameController.text = authProvider.myUser?.name??"";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit profile",
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add space before the first field
            const SizedBox(height: 20),

            // Full Name Field
            TextFormField(
              controller: _nameController,
              onChanged: (value) {
                _nameController.text=value;
                setState(() {

                });
              },
              decoration: InputDecoration(
                labelText: "Full name",
                labelStyle: TextStyle(color: Theming.primary),
                filled: true,
                fillColor: Theming.form,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller:TextEditingController(text:authProvider.myUser?.email??""),
              readOnly: true,
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



            TextFormField(
              controller: TextEditingController(text:authProvider.myUser!.phoneNumber!.substring(1)),
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Phone number",
                labelStyle: TextStyle(color: Theming.primary),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.flag),
                      SizedBox(width: 4),
                      Text("+20"),
                    ],
                  ),
                ),
                filled: true,
                fillColor: Theming.form,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            // Country Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              items: _countries
                  .map((country) => DropdownMenuItem(
                value: country,
                child: Text(country),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value!;
                });
              },
              decoration: InputDecoration(
                labelText: "Country",
                labelStyle: TextStyle(color: Theming.primary),
                filled: true,
                fillColor: Theming.form,
                border: OutlineInputBorder(),
              ),
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
                    authProvider.updateUserProfileInfo(newName: _nameController.text);
                    setState(() {
                    });
                  // Handle saving the updated information
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Profile information updated!"),
                      backgroundColor: Theming.primary, // Set background color to primary
                    ),
                  );
                },
                child: Text(
                  "SUBMIT",
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
    );
  }
}
