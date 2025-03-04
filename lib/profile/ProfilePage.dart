import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../Authentication/Login/Login_Screen.dart';
import '../Authentication/forgot_password/forgot_password_screen.dart';
import '../Firebase_Utils/Firebase_Auth.dart';
import '../Firebase_Utils/profile_setting.dart';
import '../theming.dart';
import 'EditInformation.dart';
import 'PrivacyPage.dart';
import 'CustomAlertDialog.dart';
import 'HelpSupportPage.dart';
import 'contact_us.dart';
import 'full_screen_image.dart';

class ProfilePage extends StatefulWidget {
  static const String routeName = "ProfilePage";

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late File _image;
  String? _profileImageUrl; // Store user profile image URL
  bool _isNotificationsEnabled = true; // Track notification state
  late var authProvider;
  bool _isUploading = false; // Track upload state


  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
        _isUploading = true; // Start upload indicator
      });

      // Upload and update profile picture
      await authProvider.upLoadProfileImage(image: _image);

      // Fetch the latest profile image from Firebase Auth
      User? user = FirebaseAuthService.auth.currentUser;
      setState(() {
        _profileImageUrl = user?.photoURL; // Ensure UI updates
        _isUploading = false; // Stop upload indicator
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
            authProvider.signOut(context);
            Navigator.pushReplacementNamed(context,
                LoginScreen.routeName); // Example of logout functionality
            setState(() {

            });
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
  // late MyUser myUser;

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<FirebaseAuthService>(context);
    authProvider.getUserProfileInfo();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
            onPressed: () {
              _showLogoutConfirmation(
                  context);
              setState(() {

              });// Show logout confirmation when pressed
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
                      onTap: () => Navigator.pushNamed(
                          context, EditInformationPage.routeName),
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
                  icon: Icons.password,
                  title: 'Change Password',
                  onTap: () {
                    Navigator.pushNamed(
                        context, ChangePasswordPage.routeName);
                  },
                ),
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
      Consumer<ProfileSetting>(
        builder: (context, profile, child) {
          profile.loadProfileImage();

          return  authProvider.myUser == null?Center(child: CircularProgressIndicator(),):

          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FullScreenImage()),
            ),
            child: Hero(
              tag: "profilePic",
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profile.profileImageUrl != null
                    ? NetworkImage(profile.profileImageUrl!)
                    : AssetImage("assets/Default_pfp.jpg") as ImageProvider,
              ),
            ),
          );
        }),
          SizedBox(height: 16),
          Consumer<FirebaseAuthService>(
            builder: (context, authProvider, child) {
              return authProvider.myUser == null
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Column(
                      children: [
                        Text(
                          '${authProvider.myUser?.name ?? ""}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Text('${authProvider.myUser?.email ?? ""}'),
                        Text('${authProvider.myUser?.phoneNumber ?? ""}'),
                      ],
                    );
            },
          )
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
