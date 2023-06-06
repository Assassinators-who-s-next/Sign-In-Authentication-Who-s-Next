import 'dart:io';
import 'package:basic_auth/models/user_data.dart';
import 'package:basic_auth/networking.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../globals.dart' as globals;

class ProfilePage {
  static Future<String?> retrieveImage(UserData user) async {
    try {
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('profilePictures/${user.uid}');

      final String downloadURL = await storageReference.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Error retrieving image: $e');
    }
    return null;
  }

  static Future<void> pickAndUploadImage(UserData user) async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 15);

    if (pickedFile != null) {
      ProfilePage.uploadImage(pickedFile, user);
    }
  }

  static Future<void> uploadImage(XFile photoFile, UserData user) async {
    try {
      globals.setFinishedLoadingState(false);

      final Reference storageReference =
          FirebaseStorage.instance.ref().child('profilePictures/${user.uid}');

      final metaData = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'profilePictures/': user.uid});

      final UploadTask uploadTask;
      if (defaultTargetPlatform == TargetPlatform.android) {
        uploadTask = storageReference.putFile(File(photoFile.path), metaData);
      } else {
        uploadTask =
            storageReference.putData(await photoFile.readAsBytes(), metaData);
      }

      final TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);

      final imageUrl = await taskSnapshot.ref.getDownloadURL();

      updateUserImage('imagePath', imageUrl);
      user.imagePath = imageUrl;

    } catch (e) {
      print('Error uploading image: $e');
    }

    globals.setFinishedLoadingState(true);
  }
}
