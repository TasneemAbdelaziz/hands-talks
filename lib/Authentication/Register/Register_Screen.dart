import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hands_talks/Authentication/Login/Login_Screen.dart';
import 'package:hands_talks/Authentication/Widgets/Text_Field.dart';
import 'package:hands_talks/Authentication/otp_phone.dart';
import 'package:hands_talks/Firebase_Utils/Firebase_Auth.dart';
import 'package:hands_talks/theming.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = 'register_screen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // const RegisterScreen({super.key});
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userAddressController = TextEditingController();
  final TextEditingController userPhoneController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();
  final TextEditingController userConfirmPassController =
      TextEditingController();

  bool visibility = false;
  var formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    // Dispose of the controllers to free up resources
    userNameController.dispose();
    userAddressController.dispose();
    userPhoneController.dispose();
    userPasswordController.dispose();
    userConfirmPassController.dispose();
    super.dispose();
  }

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
                    "Sign Up",
                    style: GoogleFonts.ebGaramond(
                      // textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  CustomTextField(
                    title: 'Full Name',
                    hintTitle: "Enter your full name",
                    typeKeyboard: TextInputType.name,
                    textController: userNameController,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "please enter your name";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
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
                    title: "Phone Number",
                    hintTitle: "Enter your phone number",
                    validator: (number) {
                      if (number == null || number.isEmpty) {
                        return "please enter your phone number";
                      }
                      if (number.length != 11) {
                        return "invalid phone number";
                      }
                      if (!['011', '010', '012', '015']
                          .any((prefix) => number.startsWith(prefix))) {
                        return "invalid phone number";
                      }
                      return null;
                    },
                    textController: userPhoneController,
                    typeKeyboard: TextInputType.phone,
                    icon: Icon(Icons.phone),
                  ),
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
                  SizedBox(height: 16),
                  CustomTextField(
                    title: 'Confirm Password',
                    hintTitle: 'Confirm your password',
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "please enter password";
                      }
                      if (text != userPasswordController.text) {
                        return "Password do not match";
                      }
                      return null;
                    },
                    textController: userConfirmPassController,
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        registerFormSubmit();
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
                      'Sign Up',
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
                    onPressed: () async {
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
                            context, LoginScreen.routeName);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "already have an account? ",
                          ),
                          Text(
                            "Sign in",
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

  registerFormSubmit() async {
    if (formKey.currentState?.validate() == true) {
      await FirebaseAuthService.registerWithEmailAndPassword(
          emailAddress: userAddressController.text,
          password: userPasswordController.text,
          userName: userNameController.text,
          phoneNumber: userPhoneController.text,
          context: context);


      // if (await FirebaseAuthService.checkExistingPhoneNumber(
      //         userPhoneController.text, context) ||
      //     await FirebaseAuthService.checkExistingEmail(
      //             userAddressController.text, context) ==
      //         true) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Phone number or email address is already in use.'),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      // } else {
      //   Navigator.pushNamed(context, OTPVerification.routeName, arguments: {
      //     'emailAddress': userAddressController.text,
      //     'password': userPasswordController.text,
      //     'userName': userNameController.text,
      //     'phoneNumber': userPhoneController.text
      //   });
      // }
      // FirebaseAuthService.verifyPhoneNumberWithOTP(
      //   otpCode: ,
      //     timer: ,
      //     context: context,
      //     emailAddress: userAddressController.text,
      //     password: userPasswordController.text,
      //     userName: userNameController.text,
      //     phoneNumber: userPhoneController.text);
      //Alert for successfully register

      setState(() {});
    }
  }
}
