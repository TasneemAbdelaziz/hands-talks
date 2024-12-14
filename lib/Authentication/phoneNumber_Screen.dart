import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_talks/Authentication/Widgets/Text_Field.dart';
import 'package:hands_talks/Firebase_Utils/Firebase_Auth.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'package:hands_talks/theming.dart';
import 'package:quickalert/quickalert.dart';

import '../transition/transition.dart';

class PhoneNumberScreen extends StatefulWidget {
  static const routeName = 'phoneNumberScreen';

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  TextEditingController phoneNumber = TextEditingController();
 var googleUser;

  // const PhoneNumberScreen({super.key});
  var formKey=GlobalKey<FormState>();
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    var args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
   googleUser=args!['googleUser'];
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo.jpg', // Add your image asset here
                    height: 100,
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  "Enter your phone number ",
                  style: GoogleFonts.ebGaramond(
                    // textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 24),
                Form(
                  key: formKey,
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Phone Number ",
                      style: GoogleFonts.ebGaramond(
                        // textStyle: Theme.of(context).textTheme.displayLarge,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),

                    ),const SizedBox(height: 16),
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
                      textController:phoneNumber,
                      typeKeyboard: TextInputType.phone,
                      icon: Icon(Icons.phone),
                    ),
                  ],
                )),


                 SizedBox(height:MediaQuery.sizeOf(context).height*0.3),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      phoneNumberFormSubmit();

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
                    'Send',
                    style: GoogleFonts.nunitoSans(
                      color: Theming.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));

  }

  phoneNumberFormSubmit()async  {
    if (formKey.currentState?.validate() == true) {
      // Show loading alert
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Signing In',
        text: 'Please wait...',
      );
      if (await FirebaseAuthService.checkExistingPhoneNumber(phoneNumber.text, context,) == true) {
        // Dismiss loading alert
        Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text('Phone number is already in use.'),
    backgroundColor: Colors.red,
    ),
    );

    }else{
        // Dismiss loading alert
        Navigator.pop(context);
        MyUser myUser = MyUser(
          uId: googleUser.id,
          name: googleUser.displayName ?? "Unknown",
          email: googleUser.email,
          phoneNumber:phoneNumber.text,
        );
        await FirebaseAuthService.addUserToFireCloud(myUser);
        // Show success alert
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Sign-In Successful',
          text: 'Welcome back, ${googleUser.displayName}!',
          showCancelBtn: false,
          showConfirmBtn: false,
          autoCloseDuration: Duration(seconds: 2),
        );

        // Navigate to HomePage after the timer
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pushReplacementNamed(context, Translation.routeName);
        });

  }


}
}}
