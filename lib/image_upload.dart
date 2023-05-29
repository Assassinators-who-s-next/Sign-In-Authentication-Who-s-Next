import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ImageUploader {
  Future<String?> uploadImage(File photoFile, String storageName) async {
    try {
      // Create a unique filename for the image
      //String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Get a reference to the storage bucket
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('profilePictures/$storageName');

      // Upload the file to the storage bucket
      final UploadTask uploadTask = storageReference.putFile(photoFile);

      // Await the completion of the upload task
      final TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);

      // Get the uploaded image URL
      final imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Print the uploaded image URL
      print('Image uploaded. URL: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
    }
    return null;
  }

  Future<String?> retrieveImage(String storageName) async {
    try {
      // Get a reference to the stored image
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('profilePictures/$storageName');

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
}
