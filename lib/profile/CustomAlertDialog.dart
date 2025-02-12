import 'package:flutter/material.dart';
import 'package:hands_talks/theming.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final Widget? image;
  final String positiveButtonText;
  final String negativeButtonText;
  final VoidCallback onPositivePressed;
  final VoidCallback onNegativePressed;

  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.message,
    this.image,
    required this.positiveButtonText,
    required this.negativeButtonText,
    required this.onPositivePressed,
    required this.onNegativePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theming.white,
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (image != null) image!,
          const SizedBox(height: 10),
          Text(message),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: onNegativePressed,
              child: Text(
                negativeButtonText,
                style: TextStyle(color: Theming.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 20),
            TextButton(
              onPressed: onPositivePressed,
              child: Text(
                positiveButtonText,
                style:TextStyle(color: Theming.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Theming.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
