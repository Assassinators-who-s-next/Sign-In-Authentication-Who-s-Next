import 'package:basic_auth/utils/user_preferences.dart';
import 'package:flutter/material.dart';
import 'profile_picture.dart';

class LeaderboardElemnt extends StatelessWidget {
  final String playerName;
  final int playerPoints;

  const LeaderboardElemnt(
      {super.key, required this.playerName, required this.playerPoints});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfilePicture(
          radius: 50,
          imagePath: UserPreferences
              .placeholderImage, //'assets/images/profile_picture.png',
          onClicked: () {},
        ),
        const SizedBox(width: 10),
        Text(
          playerName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
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
    // return GestureDetector(
    //   onTap: onTap,
    //   child: Container(
    //     padding: EdgeInsets.all(25),
    //     margin: EdgeInsets.symmetric(horizontal: 25.0),
    //     decoration: BoxDecoration(
    //       color: Colors.black,
    //       borderRadius: BorderRadius.circular(8), // remember to c
    //     ),
    //     child: const Center(
    //       child: Text(
    //         "Sign In",
    //         style: TextStyle(
    //           color: Colors.white,
    //           fontSize: 18,
    //           fontWeight: FontWeight.w800, // w700 is the same as bold font
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
