import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_talks/Authentication/Register/Register_Screen.dart';
import 'package:hands_talks/Authentication/Widgets/Text_Field.dart';
import 'package:hands_talks/Firebase_Utils/Firebase_Auth.dart';
import 'package:hands_talks/home/homepage.dart';
import 'package:hands_talks/theming.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // const LoginScreen({super.key});
  final TextEditingController userAddressController = TextEditingController();

  final TextEditingController userPasswordController = TextEditingController();

  bool visibility = false;

  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo.jpg', // Add your image asset here
                      height: 80,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Sign In",
                    style: GoogleFonts.ebGaramond(
                      // textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  CustomTextField(
                      title: "Email Address",
                      hintTitle: 'Enter your email',
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return "please enter your email";
                        }
                        if (EmailValidator.validate(text) == false) {
                          return "invalid email";
                        }
                        return null;
                      },
                      textController: userAddressController,
                      typeKeyboard: TextInputType.emailAddress),
                  SizedBox(height: 16),
                  CustomTextField(
                    title: "Password",
                    hintTitle: "Enter your password",
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "please enter password";
                      } else if (text.trim().length < 6) {
                        return "password must be greater than 6 character";
                      }
                      return null;
                    },
                    textController: userPasswordController,
                    typeKeyboard: TextInputType.text,
                    visiblePass: !visibility,
                    hiddenIcon: IconButton(
                      icon: Icon(visibility == false
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_sharp),
                      onPressed: () {
                        if (visibility == false) {
                          visibility = true;
                        } else {
                          visibility = false;
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  // Forgot Password Button (Styled)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot_password_screen');
                      },
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        loginFormSubmit();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Theming.primary,
                        side: BorderSide(color: Theming.primary)),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.nunitoSans(
                        color: Theming.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                      child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle Google sign-in action
                      FirebaseAuthService.signInWithGoogle(context: context);
                      setState(() {});
                    },
                    icon: Image.asset('assets/images/google.jpg',
                        height: 24), // Add Google icon asset
                    label: Text(
                      'Google',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.white,
                      // foregroundColor: Colors.black,
                      side: BorderSide(color: Theming.secondary),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: InkWell(
                      overlayColor: MaterialStatePropertyAll(Theming.secondary),
                      onTap: () {
                        Navigator.pushReplacementNamed(
                            context, RegisterScreen.routeName);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "already have not an account? ",
                          ),
                          Text(
                            "Sign up",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  loginFormSubmit() async {
    if (formKey.currentState?.validate() == true) {
      FirebaseAuthService.loginWithEmailAndPassword(
        context: context,
        emailAddress: userAddressController.text,
        password: userPasswordController.text,
      );
      //Alert for successfully login

      setState(() {
        FirebaseAuthService.loginWithEmailAndPassword(
            emailAddress: userAddressController.text,
            password: userPasswordController.text,
            context: context);
      });
    }
  }
}
