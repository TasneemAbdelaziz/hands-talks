import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_talks/theming.dart';

class CustomTextField extends StatefulWidget {
  // const CustomTextField({super.key});

  String? title;
  String? hintTitle;
  Widget? icon;
  Widget? hiddenIcon;
  bool? visiblePass;
  TextEditingController? textController;
  String? Function(String?)? validator;
  TextInputType typeKeyboard;
  CustomTextField(
      { this.title,
       this.hintTitle,
      this.icon,
      this.visiblePass,
      required this.validator,
      this.hiddenIcon,
      required this.textController,
        required this.typeKeyboard
      });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType:widget.typeKeyboard,
      controller:widget.textController ,
      validator: widget.validator,
      obscureText: widget.visiblePass ?? false,
      decoration: InputDecoration(
        contentPadding:EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          prefixIcon: widget.icon,
          suffixIcon: widget.hiddenIcon,
          label: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.title,
                  style: const TextStyle(
                    color: Colors.black, // Label color
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red, // Asterisk color
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          hintText: widget.hintTitle,
          hintStyle: GoogleFonts.nunitoSans(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theming.primary,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theming.form,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theming.form,
            ),
          )),
    );
  }
}
