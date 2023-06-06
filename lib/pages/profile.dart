import 'package:basic_auth/components/profile_text_field.dart';
import 'package:basic_auth/image_upload.dart';
import 'package:basic_auth/networking.dart';
import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../globals.dart' as globals;
import 'package:basic_auth/components/profile_picture.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = globals.myUserData;

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
                            fontSize: 40,
                          ),
                          textAlign: TextAlign.center)),
                ),
                Center(child: buildPicture(user, context)),

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
    const double pictureRadius = 250;
    const double plusIconSize = 65;
    const double plusIconDistance = pictureRadius * (.707);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(pictureRadius),
            onTap: () => ProfilePage.pickAndUploadImage(user),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children:
                [
                ProfilePicture(
                    radius: pictureRadius,
                    imagePath: user.imagePath == null || user.imagePath == ""
                        ? "lib/images/placeHolderProfileImage.jpg"
                        : user.imagePath!,
                    isNetworkPath: user.imagePath != null && user.imagePath != "",
                    onClicked: () => {}
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: plusIconDistance, top: plusIconDistance),
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          const Icon(Icons.circle, size: plusIconSize * .7, color: Colors.white),
                          Icon(Icons.add_circle, size: plusIconSize, color: Theme.of(context).colorScheme.primary)
                        ])),
                ]
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ElevatedButton(
              onPressed: () {
                logout(context);
              },
              child: const Text('Logout'),
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
            globals.myUserData.name = name;
            updateUser(context, 'name', name);
          },
          maxLength: 26,
        ),
        ProfileTextField(
          label: "Pronouns:",
          text: userData.pronouns,
          width: width,
          onChanged: (pronouns) {
            globals.myUserData.pronouns = pronouns;
            updateUser(context, 'pronouns', pronouns);
          },
          maxLength: 10,
        ),
        ProfileTextField(
          label: "About:",
          text: userData.description,
          width: width,
          onChanged: (description) {
            globals.myUserData.description = description;
            updateUser(context, 'description', description);
          },
          maxLines: 4,
          maxLength: 200,
        ),
        ProfileTextField(
          label: "Frequented Locations:",
          text: userData.frequentedLocations,
          width: width,
          onChanged: (frequentedLocations) {
            globals.myUserData.frequentedLocations =
                frequentedLocations; 
            updateUser(context, 'frequentedLocations',
                frequentedLocations); 
          },
          maxLines: 4,
          maxLength: 200,
        ),
      ],
    );
  }
}
