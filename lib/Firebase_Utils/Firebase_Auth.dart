import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/Authentication/Login/Login_Screen.dart';
import 'package:hands_talks/Authentication/Register/Register_Screen.dart';
import 'package:hands_talks/Authentication/phoneNumber_Screen.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'package:hands_talks/home/homepage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hands_talks/theming.dart';
import 'package:hands_talks/transition/transition.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
class FirebaseAuthService extends ChangeNotifier{
  MyUser? myUser;
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static bool isCorrect = true;
  static CollectionReference<MyUser> getUserCollection() {
    return FirebaseFirestore.instance.collection('users').withConverter<MyUser>(
      fromFirestore: (snapshot, _) => MyUser.fromJson(snapshot.data()!),
      toFirestore: (MyUser, _) => MyUser.toJson(),
    );
  }

  static Future<void> addUserToFireCloud(MyUser myUser) async {
    return await getUserCollection().doc(myUser.uId).set(myUser);
  }

  static checkExistingPhoneNumber(phoneNumber, context) async {
    final phoneQuery = await getUserCollection()
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();

    if (phoneQuery.docs.isNotEmpty) {
      return true;
    }
    return false;
  }

  static checkExistingEmail(emailAddress, context) async {
    final phoneQuery =
    await getUserCollection().where('email', isEqualTo: emailAddress).get();

    if (phoneQuery.docs.isNotEmpty) {
      return true;
    }
    return false;
  }





  static Future<void> registerWithEmailAndPassword(
      {required String emailAddress,
        required String password,
        required String userName,
        required String phoneNumber,
        required context}) async {
    if (await checkExistingPhoneNumber(phoneNumber, context) == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number is already in use.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Show loading alert
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Registering',
        text: 'Please wait...',
      );
      try {
        final UserCredential credential =
        await auth.createUserWithEmailAndPassword(
          email: emailAddress,
          password: password,
        );
        MyUser myUser = MyUser(
            uId: credential.user?.uid ?? "",
            name: userName,
            email: emailAddress,
            phoneNumber: phoneNumber);
        addUserToFireCloud(myUser);
        // Dismiss loading alert
        Navigator.pop(context);

        // Show success alert with timer
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Registration Successful',
          text: 'Account created successfully!',
          showCancelBtn: false, // No Cancel button
          showConfirmBtn: false,
          autoCloseDuration:
          Duration(seconds: 3), // Automatically close after 3 seconds
        );

        // Navigate to LoginScreen after the timer
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
        });
        print('User registered: ${credential.user?.email}');
      } on FirebaseAuthException catch (e) {
        // Dismiss loading alert
        Navigator.pop(context);
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('The password provided is too weak.'),
            backgroundColor: Colors.red,
          ));
        } else if (e.code ==
            'The email address is already in use by another account') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('The account already exists for that email.'),
            backgroundColor: Colors.red,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(' ${e.message}'),
            backgroundColor: Colors.red,
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  static Future<void> loginWithEmailAndPassword(
      {required emailAddress, required password, required context}) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Signing In',
      text: 'Please wait...',
    );
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      QuickAlert.show(
        context: context,
        showCancelBtn: false, // No Cancel button
        showConfirmBtn: false,
        type: QuickAlertType.success,
        title: 'Sign-In Successful',
        text: 'Welcome back, ${credential.user?.displayName ?? ""}!',
        autoCloseDuration: Duration(seconds: 3),
      );
      // Navigate to LoginScreen after the timer
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, Translation.routeName);
      });
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid login with this account try again '),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> signInWithGoogle({
    required BuildContext context,
    String? PhoneNumber,
    String? email,
  }) async {
    // Show loading alert
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Signing In',
      text: 'Please wait...',
    );

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If user cancels the sign-in process
      if (googleUser == null) {
        Navigator.pop(context); // Dismiss loading alert
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Sign-In Cancelled',
          text: 'You cancelled the Google sign-in process.',
        );
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await googleUser.authentication;

      // Dismiss loading alert
      Navigator.pop(context);

      // Check if the email exists in your system
      if (await checkExistingEmail(googleUser.email, context) == true) {
        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        // Sign in with Firebase
        await auth.signInWithCredential(credential);

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
      } else {
        // Navigate to PhoneNumberScreen
        Navigator.pushNamed(context, PhoneNumberScreen.routeName,
            arguments: {"googleUser": googleUser});


      }
    } catch (e) {
      Navigator.pop(context); // Dismiss loading alert

      // Show error message using SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid login attempt: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }





  static checkSignInState() {
    User? user = auth.currentUser;
    if (user != null) {
      return Translation
          .routeName; // Replace '/home' with your home screen route
    } else {
      return RegisterScreen.routeName;
    }
  }
   Future<void> signOut(BuildContext context) async {
    try {
      await GoogleSignIn().signOut();
      await auth.signOut();

      myUser = null; // ✅ Clear user data after logout
      notifyListeners();
      Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routeName,
            (route) => false,
      );

    } catch (e) {
      print('Error signing out: $e');
    }
  }
  getUserProfileInfo() async {
    User? user = auth.currentUser;
    if (user == null) {
      print("No user is signed in.");
      return null;
    }
    var doc = await getUserCollection().doc(user.uid).get();
    myUser = doc.data();
    notifyListeners();

  }

  Future<void> updateUserProfileInfo({String? newName}) async {
    User? user = auth.currentUser;
    if (user == null) {
      print("No user is signed in.");
      return;
    }
    // await user.updatePhotoURL(image??"");
    await getUserCollection().doc(user.uid).update(
        {
          'name': newName,

        }
    );
    notifyListeners();


  }









}