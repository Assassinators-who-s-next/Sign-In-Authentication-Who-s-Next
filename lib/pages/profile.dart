import 'package:basic_auth/auth.dart';
import 'package:basic_auth/components/profile_text_field.dart';
import 'package:basic_auth/networking.dart';
import 'package:basic_auth/utils/user_preferences.dart';
import 'package:flutter/material.dart';
import '../models/user_data.dart';
import 'join_create_game_page.dart';
import 'login_page.dart';
import 'package:basic_auth/globals.dart';

import 'package:basic_auth/components/profile_picture.dart';
//import 'package:flutter_profile_picture/flutter_profile_picture.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = myUserData;
    //final user = UserPreferences?.user;

    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                      child: Text('Profile Page',
                          style: TextStyle(
                            fontSize: 50,
                          ),
                          textAlign: TextAlign.center)),
                ),
                Center(child: buildPicture(user, context)),
                //buildPicture(myUserData, context),

                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    children: [
                      //buildDisplayedInfo(user, context),
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
          /*ProfilePicture(
            name: myUserData.name,
            role: '',
            radius: 31,
            fontsize: 21,
            tooltip: true,
            img: Image.network(myUserData.imagePath),
          ),*/

          ProfilePicture(
              radius: 250,
              //imagePath: myUserData.imagePath ?? UserPreferences.placeholderImagePath,
              imagePath: user.imagePath == null || user.imagePath == ""
                  ? "lib/images/placeHolderProfileImage.jpg"
                  : user.imagePath!,
              //isNetworkPath: user.imagePath != null,
              isNetworkPath: user.imagePath != null && user.imagePath != "",
              onClicked: () {
                print("Profile picture clicked");
              }),
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
    var width = horizontalUnit * 100;
    return Column(
      children: [
        ProfileTextField(
          label: "Name:",
          text: userData.name,
          width: width,
          onChanged: (name) {
            myUserData.name = name;
            update_user(context, 'name', name);
          },
          maxLength: 26,
        ),
        ProfileTextField(
          label: "Pronouns:",
          text: userData.pronouns,
          width: width,
          onChanged: (pronouns) {
            myUserData.pronouns = pronouns;
            update_user(context, 'pronouns', pronouns);
          },
          maxLength: 10,
        ),
        ProfileTextField(
          label: "About:",
          text: userData.description,
          width: width,
          onChanged: (description) {
            myUserData.description = description;
            update_user(context, 'description', description);
          },
          maxLines: 4,
          maxLength: 200,
        ),
        ProfileTextField(
          label: "Frequented Locations:",
          text: userData.frequentedLocations,
          width: width,
          onChanged: (frequentedLocations) {
            myUserData.frequentedLocations =
                frequentedLocations; // change locally (maybe doesn't need to happen but we'll deal with that later)
            update_user(context, 'frequentedLocations',
                frequentedLocations); // change on database
          },
          maxLines: 4,
          maxLength: 200,
        ),
      ],
    );
  }
}
