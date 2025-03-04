import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/Firebase_Utils/Firebase_Auth.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetting extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _profileImageUrl;
  bool _isLoading = false; // Loading flag

  String? get profileImageUrl => _profileImageUrl;
  bool get isLoading => _isLoading; // Getter for loading status



  /// Loads the profile image URL from Firestore.
  Future<void> loadProfileImage() async {
    try {
      _setLoading(true);
      DocumentSnapshot doc = await _firestore
          .collection("users")
          .doc(FirebaseAuthService.auth.currentUser!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _profileImageUrl = data["imageUrl"];
      } else {
        _profileImageUrl = null;
      }
    } catch (e) {
      print("Error loading profile image: $e");
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  /// Picks an image from the given [source] (camera or gallery) and uploads it.
  Future<void> pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      _setLoading(true);
      File file = File(pickedFile.path);
      String fileName = "profile_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // Upload to Firebase Storage
      TaskSnapshot snapshot =
      await _storage.ref("profile_pictures/$fileName").putFile(file);

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save URL in Firestore
      await _firestore
          .collection("users")
          .doc(FirebaseAuthService.auth.currentUser!.uid)
          .update({"imageUrl": downloadUrl});

      _profileImageUrl = downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes the current profile image from Firestore & Storage.
  Future<void> deleteImage() async {
    if (_profileImageUrl == null) return;

    try {
      _setLoading(true);

      // Delete from Storage
      await _storage.refFromURL(_profileImageUrl!).delete();

      // Remove URL from Firestore
      await _firestore
          .collection("users")
          .doc(FirebaseAuthService.auth.currentUser!.uid)
          .update({"imageUrl": FieldValue.delete()});

      _profileImageUrl = null;
    } catch (e) {
      print("Error deleting image: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Updates the loading state and notifies listeners.
  void _setLoading(bool value) {
    _isLoading = value;
    // notifyListeners();
  }

  Future<void> addReports({required name,required String email,required String message})async {
    await FirebaseFirestore.instance.collection('reports').add({
      'name': name,
      'email': email,
      'message': message,
      "date": DateTime.now().toString(),
    });
 notifyListeners();
  }
}
