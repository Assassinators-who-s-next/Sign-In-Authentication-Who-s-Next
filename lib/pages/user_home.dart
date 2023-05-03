import 'package:basic_auth/components/game_list_drawer.dart';
import 'package:basic_auth/components/profile_picture.dart';
import 'package:basic_auth/utils/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:basic_auth/models/user_data.dart';

class UserHome extends StatefulWidget {
  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  List<String> numActiveGames = [
    'Game A',
    'Game B',
    'Game C',
    'Game D',
    'Game E',
    'Game F',
    'Game G',
    'Game H',
    'Game I',
    'Game J',
  ];

  bool? isCheckedBox = false;

  @override
  Widget build(BuildContext context) {
    // for sizing the image
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    // if the orientation is landscape, size changes to the height of the device
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      var width = screenWidth;
      screenWidth = screenHeight;
      screenHeight = width;
    }

    return GameListDrawer(
        numActiveGames: numActiveGames,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        content: homeScreenContent(context, screenWidth, screenHeight));
  }
}

Widget homeScreenContent(BuildContext context, double screenWidth, double screenHeight) {
  bool gameStarted = false;
  return Stack(children: [
    InfoButton(context, screenWidth, screenHeight),
    gameStarted ? eliminationTargetScreen(screenWidth) : prematchScreen(screenWidth),
  ]);
}

Center eliminationTargetScreen(double screenWidth) {
  UserData targetData = UserPreferences.user;
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TargetName(username: targetData.name),
        ProfilePicture(
            radius: screenWidth * .40,
            imagePath: targetData.imagePath ?? UserPreferences.placeholderImagePath,
            isNetworkPath: true,
            onClicked: () => print("clicked elimation target")),
        Padding(
          padding: const EdgeInsetsDirectional.all(40),
          child: LargeUserHomeButton(label: "Eliminate", color: Color.fromARGB(255, 238, 127, 119), onPressed: () => print('pressed elim button')),
        ),
      ],
    ),
  );
}

Center prematchScreen(double screenWidth) {
  int maxPlayersInMatch = 2;
  int playersInMatch = 1;
  return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Padding(
      padding: const EdgeInsets.all(20),
      child: Text("Players In Match: ", style: TextStyle(fontSize: 30)),
    ),
    Text("${playersInMatch}/${maxPlayersInMatch}", style: TextStyle(fontSize: 25)),
    Padding(
      padding: const EdgeInsetsDirectional.all(40),
      child:
          LargeUserHomeButton(label: "Start match", color: Color.fromARGB(255, 43, 167, 204), onPressed: () => print("pressed start match button")),
    ),
  ]));
}

Container InfoButton(BuildContext context, double screenWidth, double screenHeight) {
  double size = screenWidth * .075;
  return Container(
    child: Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(size),
          onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: const Text("Match Info: ", style: const TextStyle(fontSize: 30)),
                    content: Container(child: Text("Rules: "), width: screenWidth * .9, height: screenHeight * .9),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close", style: TextStyle(fontSize: 18))),
                    ],
                  )),
          child: Icon(Icons.info, size: size),
        ),
      ),
    ),
  );
}

class LargeUserHomeButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  const LargeUserHomeButton({
    required this.label,
    required this.color,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size.fromHeight(50),
        textStyle: TextStyle(fontSize: 25),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class TargetName extends StatelessWidget {
  final String username;
  const TargetName({
    required this.username,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.all(40),
      child: Text('Target: ${username}', style: TextStyle(fontSize: 30), textAlign: TextAlign.center),
    );
  }
}