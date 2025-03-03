import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/Authentication/Login/Login_Screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../theming.dart';
import 'EditInformation.dart';
import 'PrivacyPage.dart';
import 'CustomAlertDialog.dart';
import 'HelpSupportPage.dart';
import 'contact_us.dart';

class ProfilePage extends StatefulWidget {
  static const String routeName = "ProfilePage";

  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image; // Selected profile picture
  bool _isNotificationsEnabled = true; // Track notification state

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  // Show logout confirmation using the custom alert dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomAlertDialog(
          title: 'Are You Logging Out?',
          message: 'Come back soon!',
          image: Image.asset('assets/logout.png', height: 200),
          positiveButtonText: 'Logout',
          negativeButtonText: 'Cancel',
          onPositivePressed: () {
            Navigator.of(dialogContext).pop(); // Close the dialog
            Navigator.pushReplacementNamed(context, '/'); // Example of logout functionality
          },
          onNegativePressed: () {
            Navigator.of(dialogContext).pop(); // Close the dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cancel clicked')),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBF0F0),
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theming.primary,
          ),
        ),
        actions: [

          IconButton(
            icon: Icon(Icons.logout, size: 30, color: Theming.primary),
            onPressed: () async{
             await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              // _showLogoutConfirmation(context);// Show logout confirmation when pressed
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Background.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildSettingsBox([
                    _buildSettingsTile(
                      icon: Icons.edit,
                      title: 'Edit profile information',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditInformationPage(),
                        ),
                      ),
                    ),
                    _buildSettingsTile(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      trailing: Switch(
                        value: _isNotificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isNotificationsEnabled = value;
                          });
                        },
                      ),
                      onTap: () {},
                    ),
                    _buildSettingsTile(
                      icon: Icons.language,
                      title: 'Language',
                      onTap: () {
                        // Implement language settings navigation
                      },
                    ),
                  ]),
                  _buildSettingsBox([
                    _buildSettingsTile(
                      icon: Icons.security,
                      title: 'Security',
                      onTap: () {},
                    ),
                    _buildSettingsTile(
                      icon: Icons.color_lens,
                      title: 'Theme',
                      onTap: () {
                        // Implement theme settings navigation
                      },
                    ),
                  ]),
                  _buildSettingsBox([
                    _buildSettingsTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportPage(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.contact_mail,
                      title: 'Contact us',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactUsPage(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.privacy_tip,
                      title: 'Privacy policy',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrivacyPage(),
                          ),
                        );
                      },
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: _image != null
                  ? FileImage(_image!)
                  : const AssetImage('assets/Default_pfp.jpg') as ImageProvider,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Muhammed',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text('muhammed22@gmail.com'),
          const Text('+01234567890'),
        ],
      ),
    );
  }

  Widget _buildSettingsBox(List<Widget> tiles) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: tiles,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
