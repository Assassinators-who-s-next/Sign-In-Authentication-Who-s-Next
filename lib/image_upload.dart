import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();
  late File _imageFile;
  String _imageUrl = '';

  Future<void> uploadImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      try {
        // Create a unique filename for the image
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();

        // Get a reference to the storage bucket
        final Reference storageReference =
            FirebaseStorage.instance.ref().child('profilePictures/$fileName');

        // Upload the file to the storage bucket
        final UploadTask uploadTask = storageReference.putFile(_imageFile);

        // Await the completion of the upload task
        final TaskSnapshot taskSnapshot =
            await uploadTask.whenComplete(() => null);

        // Get the uploaded image URL
        final imageUrl = await taskSnapshot.ref.getDownloadURL();

        setState(() {
          _imageUrl = imageUrl;
        });

        // Print the uploaded image URL
        print('Image uploaded. URL: $_imageUrl');
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> retrieveImage() async {
    try {
      // Get a reference to the stored image
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('profilePictures/example.jpg');

      // Retrieve the download URL for the stored image
      final String downloadURL = await storageReference.getDownloadURL();

      // Print the retrieved image URL
      print('Retrieved image URL: $downloadURL');
    } catch (e) {
      print('Error retrieving image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: uploadImage,
              child: Text('Upload Image'),
            ),
            ElevatedButton(
              onPressed: retrieveImage,
              child: Text('Retrieve Image'),
            ),
            SizedBox(height: 20),
            _imageUrl.isNotEmpty
                ? Image.network(
                    _imageUrl,
                    height: 200,
                  )
                : Text('No image selected'),
          ],
        ),
      ),
    );
  }
}
