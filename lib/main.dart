import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hands_talks/Authentication/Login/Login_Screen.dart';
import 'package:hands_talks/Authentication/Register/Register_Screen.dart';
import 'package:hands_talks/Authentication/otp_phone.dart';
import 'package:hands_talks/Authentication/phoneNumber_Screen.dart';
import 'package:hands_talks/Firebase_Utils/Firebase_Auth.dart';
import 'package:hands_talks/home/homepage.dart';
//import 'package:hands_talks/message/chatpage.dart';
// import 'package:hands_talks/message/messagepage.dart';
import 'package:hands_talks/message/chatpage.dart';
import 'package:hands_talks/message/messagespage.dart';
import 'package:hands_talks/message/chatpage.dart';
import 'package:hands_talks/profile/EditInformation.dart';
import 'package:hands_talks/profile/ProfilePage.dart';
import 'package:hands_talks/transition/transition.dart';
import 'package:hands_talks/translate/speechToSign/speech_processing.dart';
import 'package:hands_talks/translate/speechToSign/text_processing.dart';
import 'package:hands_talks/translate/translatepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'Authentication/forgot_password/forgot_password_screen.dart';
import 'firebase_options.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,);
  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) =>FirebaseAuthService() ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize:  Size(375, 812),
      splitScreenMode:true,
      minTextAdapt: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute:SpeechProcessing.routeName,
        routes: {
          RegisterScreen.routeName:(context) => RegisterScreen(),
          LoginScreen.routeName:(context) => LoginScreen(),
          '/forgot_password_screen': (context) => ChangePasswordPage(),
          PhoneNumberScreen.routeName:(context) => PhoneNumberScreen(),
          // OTPVerification.routeName:(context) => OTPVerification(),
          Translation.routeName: (context) => Translation(),
          HomePage.routeName: (context) => HomePage(),
          TranslatePage.routeName: (context) => TranslatePage(),
          SpeechProcessing.routeName:(context)=> SpeechProcessing(),
          TextProcessing.routeName:(context)=> TextProcessing(),
         ProfilePage.routeName:(context)=> ProfilePage(),
          EditInformationPage.routeName: (context) => EditInformationPage(),
          ChatPage.routeName: (context) => const ChatPage()
      
        },
      
      
      ),
    );
  }
}
