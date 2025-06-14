import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hands_talks/theming.dart';

class TranslatePage extends StatelessWidget {
  static const String routeName = "TranslatePage";
  const TranslatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 680.h),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            fillColor: Colors.white70,
                            filled: true,
                            hintText: "Type to translate",
                            hintStyle: TextStyle(
                                color: Color(0xff495466), fontSize: 24),
                            suffixIcon: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, 'SignToTextProcessing');
                              },
                              icon: Icon(Icons.camera_alt_rounded),
                              color: Color(0xff495466),
                              iconSize: 45,
                            )),
                      ),
                    ),
                    SizedBox(width: 25.w),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: Theming.icons,
                      ),
                      child: IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'SpeechProcessing');
                          },
                          icon: Icon(
                            Icons.mic_none_outlined,
                            color: Theming.white,
                            size: 45,
                          )),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
