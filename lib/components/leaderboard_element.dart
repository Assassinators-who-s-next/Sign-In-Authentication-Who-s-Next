import 'package:basic_auth/globals.dart';
import 'package:basic_auth/utils/user_preferences.dart';
import 'package:flutter/material.dart';
import 'profile_picture.dart';

class LeaderboardElemnt extends StatelessWidget {
  final String playerName;
  final int playerPoints;

  const LeaderboardElemnt(
      {super.key, required this.playerName, required this.playerPoints});

  String getName() {
    return this.playerName;
  }

  String getPoints() {
    return '${this.playerPoints}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfilePicture(
          radius: 50,
          imagePath: UserPreferences.placeholderImagePath,
          //imagePath: myUserData.imagePath!,
          isNetworkPath: false,
          onClicked: () {},
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            playerName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Spacer(),
        Text(
          playerPoints.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
