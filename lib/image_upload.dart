import 'dart:io';

import 'package:basic_auth/globals.dart';
import 'package:basic_auth/models/user_data.dart';
import 'package:basic_auth/networking.dart';
import 'package:basic_auth/pages/home_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage {
  static Future<String?> retrieveImage(UserData user) async {
    try {
      // Get a reference to the stored image
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('profilePictures/${user.uid}');

      // Retrieve the download URL for the stored image
      final String downloadURL = await storageReference.getDownloadURL();

      // Print the retrieved image URL
      print('Retrieved image URL: $downloadURL');
      return downloadURL;
    } catch (e) {
      print('Error retrieving image: $e');
    }
    return null;
  }

  static Future<void> pickAndUploadImage(UserData user) async {
    final ImagePicker _imagePicker = ImagePicker();
    final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 15);

    if (pickedFile != null) {
      ProfilePage._uploadImage(pickedFile, user);
    }
  }

  static Future<void> _uploadImage(XFile photoFile, UserData user) async {
    try {
      SetFinishedLoadingState(false);
      // Get a reference to the storage bucket
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('profilePictures/${user.uid}');

      print('created storage refernce');
      final metaData = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'profilePictures/': user.uid});

      // Upload the file to the storage bucket
      final UploadTask uploadTask;
      if (defaultTargetPlatform == TargetPlatform.android) {
        uploadTask = storageReference.putFile(File(photoFile.path), metaData);
      } else {
        uploadTask =
            storageReference.putData(await photoFile.readAsBytes(), metaData);
      }
      print('uploaded file to storage bucket');

      // Await the completion of the upload task
      final TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);
      print('waiting for upload task completion');

      // Get the uploaded image URL
      final imageUrl = await taskSnapshot.ref.getDownloadURL();
      print('get image url');

      update_user_image('imagePath', imageUrl);
      user.imagePath = imageUrl;

      // Print the uploaded image URL
      print('Image uploaded. URL: $imageUrl');
    } catch (e) {
      print('Error uploading image: $e');
    }

    SetFinishedLoadingState(true);
  }
}
