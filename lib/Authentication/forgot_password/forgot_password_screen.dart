import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isEmailNotEmpty = false; // Tracks if email input is filled
  bool isLoading = false; // For showing progress indicator

  @override
  void initState() {
    super.initState();
    // Add listener to email input
    emailController.addListener(() {
      setState(() {
        isEmailNotEmpty = emailController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // Function to send password reset email
  Future<void> sendPasswordResetEmail() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reset password email sent! Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error: $e'); // Print the exact Firebase error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40), // Space for status bar
            // Back Arrow
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 20),

            // Logo (Center Aligned)
            Center(
              child: Image.asset(
                'assets/images/logo.jpg', // Replace with your app's logo asset
                height: 100,
              ),
            ),
            SizedBox(height: 30),

            // Title: Change Password
            Center(
              child: Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Subtitle: Instructions
            Center(
              child: Text(
                'Enter your email account to receive a verification code to change your password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
            SizedBox(height: 30),

            // Email Label
            Text(
              'Email',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),

            // Email Input Field
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 40),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isEmailNotEmpty ? Color(0xFF0A3977) : Colors.grey[300],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: isEmailNotEmpty && !isLoading
                    ? sendPasswordResetEmail
                    : null,
                child: isLoading
                    ? CircularProgressIndicator(
                  color: Colors.white,
                )
                    : Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: isEmailNotEmpty
                        ? Colors.white
                        : Colors.grey[500],
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
