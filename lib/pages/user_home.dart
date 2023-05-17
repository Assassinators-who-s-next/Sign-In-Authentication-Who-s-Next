import 'package:basic_auth/components/game_list_drawer.dart';
import 'package:basic_auth/components/profile_picture.dart';
import 'package:basic_auth/globals.dart';
import 'package:basic_auth/models/match_options.dart';
import 'package:basic_auth/utils/popup_modal.dart';
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

Widget homeScreenContent(
    BuildContext context, double screenWidth, double screenHeight) {
  bool gameStarted = true;
  return Stack(children: [
    InfoButton(context, screenWidth, screenHeight),
    gameStarted
        ? eliminationTargetScreen(screenWidth, screenHeight, context)
        : prematchScreen(screenWidth),
  ]);
}

Center eliminationTargetScreen(double screenWidth, double screenHeight,BuildContext context) {
  //UserData targetData = myUserData;
  //UserData targetData = UserPreferences.user;
  UserData targetData = UserData(
      description: '',
      email: '',
      frequentedLocations: '',
      imagePath: '',
      name: 'Joshua',
      pronouns: '',
      uid: '');
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TargetName(username: targetData.name),
        ProfilePicture(
            radius: screenWidth * .40,
            imagePath: targetData.imagePath!,
            //imagePath: targetData.imagePath ?? UserPreferences.placeholderImagePath,
            isNetworkPath: true,
            onClicked: () => print("clicked elimation target")),
        Padding(
          padding: const EdgeInsetsDirectional.all(40),
          child: LargeUserHomeButton(
              label: "Eliminate",
              color: Color.fromARGB(255, 238, 127, 119),
              onPressed: () => {eliminateNoti(targetData, context, screenWidth, screenHeight)}),
        ),
      ],
    ),
  );
}

Future eliminateNoti(UserData targetData, BuildContext context, double screenWidth, double screenHeight) {
  return showSimplePopup(
    context,
    title: "Eliminate",
    contentText: "You got eliminated by ${targetData.name}. Is this you?",
    bottomWidgets: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 238, 127, 119),
              minimumSize: Size(screenWidth * 0.25, screenHeight * 0.05),
              textStyle: TextStyle(fontSize: 25),
            ),
            onPressed: () => print("eliminated"),
            child: Text("Yes"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 43, 167, 204),
              minimumSize: Size(screenWidth * 0.25, screenHeight * 0.05),
              textStyle: TextStyle(fontSize: 25),
            ),
            onPressed: () => print("eliminated failed"),
            child: Text("No"),
          ),
        ],
      )
    ],
    width: screenWidth * 0.5,
    height: screenHeight * 0.1,
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
    Text("${playersInMatch}/${maxPlayersInMatch}",
        style: TextStyle(fontSize: 25)),
    Padding(
      padding: const EdgeInsetsDirectional.all(40),
      child: LargeUserHomeButton(
          label: "Start match",
          color: Color.fromARGB(255, 43, 167, 204),
          onPressed: () => print("pressed start match button")),
    ),
  ]));
}

Container InfoButton(
    BuildContext context, double screenWidth, double screenHeight) {
  double size = screenWidth * .075;
  return Container(
    child: Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(size),
          onTap: () => showPopup(
            context,

            // {
            //   const Text("Match Info: ", style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
            //   AboutPopupContent(),
            //   [
            //     closeButton(context),
            //   ],
            //   screenWidth * .9, //width
            //   screenHeight * .9, //height
            // }
          ),
          child: Icon(Icons.info, size: size),
        ),
      ),
    ),
  );
}

Widget AboutPopupContent() {
  MatchOptions exampleOptions = MatchOptions("Finger Guns", "Week", 2, "Month",
      3, "During class, in library", "Floaties");
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      MatchInfoText("Game Period",
          "${exampleOptions.totalGameTimeDuration} ${exampleOptions.totalGameTimeType}(s)"),
      MatchInfoText("Respawn Time",
          "${exampleOptions.respawnDuration} ${exampleOptions.respawnTimeType}(s)"),
      MatchInfoText("Permitted Elimation Type", exampleOptions.eliminationType),
      MatchInfoText("Off Limit Areas", exampleOptions.offLimitAreas),
      MatchInfoText("Safety Methods", exampleOptions.safetyMethods),
    ],
  );
}

Column MatchInfoText(String label, String text) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("${label}: ",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text(text),
      SizedBox(
        height: 15,
      ),
    ],
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
      child: Text('Target: ${username}',
          style: TextStyle(fontSize: 30), textAlign: TextAlign.center),
    );
  }
}
