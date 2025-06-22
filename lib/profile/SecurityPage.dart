import 'package:flutter/material.dart';

class Securitypage extends StatelessWidget {
  const Securitypage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Text Security'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '1. App Privacy',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Our app is built with your privacy in mind. We ensure that your personal information stays protected and is never shared without your permission. Your data is safe within the app and is handled with care.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '2. Secure Communication',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Every message or input you make is treated securely. Whether you\'re chatting, entering text, or using any feature, we make sure the content is protected from unauthorized access.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '3. Trusted Environment',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We use secure technologies and best practices to create a safe environment for you. You can trust that everything you do inside the app is private and handled responsibly.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
