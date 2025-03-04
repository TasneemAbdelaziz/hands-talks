import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hands_talks/translate/speechToSign/speech_processing.dart';

import '../../theming.dart';

class TextProcessing extends StatefulWidget {
  static const String routeName = "TextProcessing";

  const TextProcessing({super.key});

  @override
  State<TextProcessing> createState() => _TextProcessingState();
}

class _TextProcessingState extends State<TextProcessing> {


  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments as Map?;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(7.0),
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            enableFeedback: false,
            shape: CircleBorder(),
            elevation: 3,
            child: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Padding(padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        children: [
          Image.asset("assets/images/animation.png" , width: 568.w,
            height: 379.19.h,fit:BoxFit.fill,filterQuality: FilterQuality.high,),
          SizedBox(height: 20.h,),
          Container(
            width:348.w ,
            height:129.91.h ,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(),
              color: Colors.white,),
              child: Column(
                children: [
                  CustomPaint(
                    size: Size(MediaQuery.of(context).size.width * 0.8, 50.h), // Adjust size as needed
                    painter: WaveformPainter(args!['waveformValues']),
                  )
                  ,
                  SizedBox(height: 25.h,),
                  Row(
                    children: [
                      InkWell(
                        onTap: (){
                        },
                        child: Container(
                          child: Text("to text",textAlign:TextAlign.center,style:TextStyle(fontSize: 10.sp),),
                          height:30.h ,
                          width:115.w ,
                          margin: EdgeInsets.only(right:5.w,left: 11.w),
                          decoration: BoxDecoration(
                            color:Theming.searchbar ,
                            borderRadius: BorderRadius.circular(22.r),
                            border: Border.all()
                          ),
                        ),
                      ), InkWell(
                        onTap: (){
                        },
                        child: Container(
                          child: Text("to visualize",textAlign:TextAlign.center,style:TextStyle(fontSize: 10.sp),),
                          height:30.h ,
                          width:115.w ,
                          decoration: BoxDecoration(
                            color:Theming.white ,
                            borderRadius: BorderRadius.circular(22.r),
                            border: Border.all()
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
          ),
          SizedBox(height: 25.h,),
          Container(

            padding: EdgeInsets.only(
              right:8.w ,
              bottom:13.h ,
              top:5.h ,
              left:81.w ,
            ),
            child: Text(" ${args?['lastWords'] ?? "No text detected"}",style: TextStyle(

              fontSize: 10.sp
            ),),
            alignment: Alignment.bottomRight,
            decoration: BoxDecoration(
              border:
                Border.all(),
              borderRadius: BorderRadius.circular(22.r),
              color: Colors.white,
            ),
          )
        ],
      ),
      ),
    );
  }
}
