import 'package:flutter/material.dart';
import '../theming.dart';

class HelpSupportPage extends StatelessWidget {
  static const String routeName = 'HelpSupportPage';

  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('Help & Support',
        style: TextStyle(color: Theming.primary),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Help Articles'),
              onTap: () {
                // Navigate to help articles page
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Live Chat Support'),
              onTap: () {
                // Implement live chat functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Support'),
              onTap: () {
                // Implement email contact support functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Support'),
              onTap: () {
                // Implement call support functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
