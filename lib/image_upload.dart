import 'dart:io';

import 'package:basic_auth/globals.dart';
import 'package:basic_auth/models/user_data.dart';
import 'package:basic_auth/networking.dart';
import 'package:basic_auth/pages/home_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  //Future<String?> retrieveImage(String storageName) async {
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

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();
  late File _imageFile;
  String _imageUrl = '';

  //final String testUserID = "user16";

  //Future<void> pickAndUploadImage(String storageName) async {
  Future<void> pickAndUploadImage(UserData user) async {
    //final pickedFile = await _imagePicker.getImage(source: ImageSource.gallery);
    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      //uploadImage(_imageFile, user);
      uploadImage(pickedFile, user);
    }
  }

  //Future<void> uploadImage(File photoFile, String storageName) async {
  Future<void> uploadImage(XFile photoFile, UserData user) async {
    try {
      // Create a unique filename for the image
      //String fileName = DateTime.now().millisecondsSinceEpoch.toString();

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

      setState(() {
        _imageUrl = imageUrl;

        user.imagePath = imageUrl;

        update_user(context, 'imagePath', imageUrl);
      });

      // Print the uploaded image URL
      print('Image uploaded. URL: $_imageUrl');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(myUserData.uid);
    final user = myUserData;
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => HomePage(),
                ));
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  //pickAndUploadImage(testUserID);
                  //pickAndUploadImage(myUserData.uid);
                  pickAndUploadImage(user);
                },
                child: Text('Upload Image'),
              ),
              //            ElevatedButton(
              //              onPressed: () async {
              //                //retrieveImage(testUserID);
              //                //retrieveImage(myUserData.uid);
              //                await ProfilePage.retrieveImage(user);
              //              },
              //              child: Text('Retrieve Image'),
              //            ),
              SizedBox(height: 30),
              _imageUrl.isNotEmpty
                  ? Column(
                      children: [
                        Image.network(
                          _imageUrl,
                          //                ? Image.network(
                          //                    _imageUrl,
                          height: 200,
                        ),
                        const Text('Image updated!')
                      ],
                    )
                  : const Text('No image selected'),
            ],
          ),
        ),
      ),
    );
  }
}
