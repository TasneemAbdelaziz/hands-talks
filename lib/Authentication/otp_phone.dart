import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_talks/Firebase_Utils/Firebase_Auth.dart';
import 'package:hands_talks/theming.dart';

class OTPVerification extends StatefulWidget {
  static String routeName = 'OTPVerification';
  List<TextEditingController> controllers = List.generate(6, (index) => TextEditingController());
  Timer? _timer;
  int _start = 30;
  String? otpCode;
  String? password;
  String? userName;
  String? phoneNumber;
  String? emailAddress;
  OTPVerification(
      { this.emailAddress,
       this.password,
       this.userName,
       this.phoneNumber});

  @override
  State<OTPVerification> createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    widget._timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (widget._start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            widget._start--;
          });
        }
      },
    );
  }

  // const OTPVerification({super.key});
  bool? last = false;

bool isCorrect=FirebaseAuthService.isCorrect;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    widget.emailAddress=args?['emailAddress'];
    widget.password=args?['password'];
    widget.userName=args?['userName'];
    widget.phoneNumber=args?['phoneNumber'];

  }
  @override
  void initState() {
    startTimer();

    super.initState();
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
                  "OTP Verification",
                  style: GoogleFonts.ebGaramond(
                    // textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // Instruction Text
                Text(
                  textAlign: TextAlign.center,
                  'Enter the code from the SMS we sent to ${widget.phoneNumber}',
                  style: GoogleFonts.nunitoSans(
                    color: Theming.form,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return Container(
                      height: 60,
                      width: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color:isCorrect? Theming.primary:Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                         controller: widget.controllers[index],
                        onChanged: (value) {
                          if (value.isNotEmpty && index != 5) {
                            FocusScope.of(context).nextFocus();
                          } else if (value.isEmpty && index != 0) {
                            FocusScope.of(context).previousFocus();
                          }
                          if (index == 5 && value.isNotEmpty) {
                            last = true;
                          } else {
                            last = false;
                          }
                          setState(() {
                            widget.otpCode = widget.controllers.map((controller) => controller.text).join();
                          });
                        },
                        inputFormatters: [LengthLimitingTextInputFormatter(1)],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20),
                        maxLength: 1,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: ""
                          // Removes counter below the TextField
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // Resend Code + Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive code?",
                      style: GoogleFonts.nunitoSans(
                        color: Theming.form,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed:widget._start!=0?null: () {
                        setState(() {
                          // widget._start=60;
                          // startTimer();
                          // FirebaseAuthService.verifyPhoneNumberWithOTP(
                          //     emailAddress: widget.emailAddress ?? "",
                          //     password: widget.password ?? "",
                          //     userName: widget.userName ?? "",
                          //     phoneNumber: widget.phoneNumber ?? '',
                          //     otpCode: widget.otpCode,
                          //     timer: widget._start,
                          //     context: context);
                        });

                      },
                      child: Text(
                        'Resend',
                        style: GoogleFonts.nunitoSans(
                          color:widget._start==0? Theming.primary:Theming.form,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Timer

                Text(
                  '${widget._start.toString()}:00',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: last == false
                      ? null
                      : () {
                          setState(() {
                            // FirebaseAuthService.verifyPhoneNumberWithOTP(
                            //     emailAddress: widget.emailAddress ?? "",
                            //     password: widget.password ?? "",
                            //     userName: widget.userName ?? "",
                            //     phoneNumber: widget.phoneNumber ?? '',
                            //     otpCode: widget.otpCode,
                            //     timer: widget._start,
                            //     context: context);
                          });
                        },
                  style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor:
                          last == true ? Theming.primary : Theming.form,
                      side: BorderSide(color: Theming.primary)),
                  child: Text(
                    'Get OPT',
                    style: GoogleFonts.nunitoSans(
                      color: last == false ? Theming.primary : Theming.white,
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
}
