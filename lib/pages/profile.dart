import 'package:basic_auth/auth.dart';
import 'package:basic_auth/components/profile_picture.dart';
import 'package:basic_auth/components/profile_text_field.dart';
import 'package:basic_auth/models/user_data.dart';
import 'package:basic_auth/networking.dart';
import 'package:basic_auth/utils/user_preferences.dart';
import 'package:flutter/material.dart';
import 'join_create_game_page.dart';
import 'login_page.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = UserPreferences.user;

    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text('Profile Page',
                      style: TextStyle(fontSize: 50)),
                ),
                buildPicture(user, context),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    children: [
                      buildDisplayedInfo(user, context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Padding buildPicture(UserData user, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          ProfilePicture(
            radius: 250,
            imagePath: user.imagePath ?? UserPreferences.placeholderImagePath,
            isNetworkPath: false,
            onClicked: () => print("Profile picture clicked"),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: ElevatedButton(
              onPressed: () {
                logout(context);
              },
              child: Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDisplayedInfo(UserData userData, BuildContext context) {
    var mediaQueryData = MediaQuery.of(context);
    var horizontalUnit = mediaQueryData.size.width / 100;
    var width = horizontalUnit * 85;
    return Column(
      children: [
        ProfileTextField(
          label: "Name:",
          text: userData.name,
          width: width,
          onChanged: (name) {},
          maxLength: 26,
        ),
        ProfileTextField(
          label: "Pronouns:",
          text: userData.pronouns,
          width: width,
          onChanged: (pronouns) {},
          maxLength: 10,
        ),
        ProfileTextField(
          label: "About:",
          text: userData.description,
          width: width,
          onChanged: (description) {},
          maxLines: 4,
          maxLength: 200,
        ),
        ProfileTextField(
          label: "Frequented Locations:",
          text: userData.frequentedLocations,
          width: width,
          onChanged: (frequentedLocations) {},
          maxLines: 4,
          maxLength: 200,
        ),
      ],
    );
  }
}
