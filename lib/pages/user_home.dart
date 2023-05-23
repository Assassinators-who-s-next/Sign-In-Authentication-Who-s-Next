import 'package:basic_auth/components/game_list_drawer.dart';
import 'package:basic_auth/components/profile_picture.dart';
import 'package:basic_auth/globals.dart';
import 'package:basic_auth/models/match_options.dart';
import 'package:basic_auth/utils/popup_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:basic_auth/models/user_data.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:basic_auth/networking.dart';
import 'package:basic_auth/pages/join_create_game_page.dart';

import '../game_group.dart';

class UserHome extends StatefulWidget {
  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  bool? isCheckedBox = false;
  late Group selGroup;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      selGroup = selectedGroup;
    });
  }

  void SetSelectedGroup(Group group) {
    selectedGroup = group;
    setState(() {
      selGroup = group;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      var width = screenWidth;
      screenWidth = screenHeight;
      screenHeight = width;
    }

    return myGroups.isEmpty
        ? noGroupScreenContent(context)
        : GameListDrawer(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            content: homeScreenContent(context, screenWidth, screenHeight),
            onSelectGroup: (p0) => SetSelectedGroup(p0),
          );
  }
}

Widget noGroupScreenContent(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text("No Group Selected", style: TextStyle(fontSize: 30)),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.all(40),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 43, 167, 204),
              minimumSize: Size(200, 50),
              textStyle: TextStyle(fontSize: 25),
            ),
            onPressed: () => {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JoinCreatePage(),
                  )),
              print("pressed join/create button")
            },
            child: Text("Join/Create"),
          ),
        ),
      ],
    ),
  );
}

Widget homeScreenContent(
    BuildContext context, double screenWidth, double screenHeight) {
  bool gameStarted = true;
  // bool gameStarted = true;

  return Stack(children: [
    InfoButton(context, screenWidth, screenHeight),
    gameStarted
        ? eliminationTargetScreen(screenWidth, screenHeight, context)
        : prematchScreen(screenWidth),
  ]);
}

Center eliminationTargetScreen(
    double screenWidth, double screenHeight, BuildContext context) {
  //UserData targetData = myUserData;
  //UserData targetData = UserPreferences.user;
  UserData targetData = UserData(
      description: "it's a me",
      email: "email here",
      frequentedLocations: "joe's crab shack",
      imagePath: "image here",
      name: 'Cashmoney',
      pronouns: 'he/him',
      uid: 'uid');
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
              buttonState: true,
              onPressed: () => {
                    eliminateNoti(
                        targetData, context, screenWidth, screenHeight)
                  }),
        ),
      ],
    ),
  );
}

Future eliminateNoti(UserData targetData, BuildContext context,
    double screenWidth, double screenHeight) {
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

//Center prematchScreen(double screenWidth) {
StreamBuilder prematchScreen(double screenWidth) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('groups')
        .doc(selectedGroup.group_name)
        .collection('players')
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      // error
      if (snapshot.hasError) {
        return Center(
            child: Text('Error loading game ${selectedGroup.group_name}'));
        // receiving data
      } else if (snapshot.connectionState == ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsetsDirectional.all(20),
          child: Center(child: CircularProgressIndicator()),
        );
//          return const Center(child: Text('Loading'));
      }
//        print('${snapshot.data!.size}');

      bool enoughPlayers = false;
      if (snapshot.data!.size >= 2) {
        enoughPlayers = true;
      }
      ;
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text("Players In Match: ", style: TextStyle(fontSize: 30)),
        ),
        Text("${snapshot.data!.size}/${selectedGroup.matchOptions.maxPlayers}",
            style: const TextStyle(fontSize: 25)),
        Padding(
          padding: const EdgeInsetsDirectional.all(40),
          child: LargeUserHomeButton(
            label: "Start match",
            color: const Color.fromARGB(255, 43, 167, 204),
            //currPlayers: snapshot.data!.size,
            buttonState: enoughPlayers,
            onPressed: () {
              print("pressed start match button");
              startGameOrRespawn();
            },
          ),
        )
      ]));
    },
  );
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
          onTap: () => {
            showPopup(
              context,
              title: Text("Match Info: ",
                  style: const TextStyle(
                      fontSize: 35, fontWeight: FontWeight.bold)),
              content: AboutPopupContent(),
              bottomWidgets: [
                closeButton(context),
              ],
              width: screenWidth * .9, //width
              height: screenHeight * .9, //height
            )
          },
          child: Icon(Icons.info, size: size),
        ),
      ),
    ),
  );
}

Widget AboutPopupContent() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      MatchInfoText("Game Period",
          "${selectedGroup.matchOptions.totalGameTimeDuration} ${selectedGroup.matchOptions.totalGameTimeType}"),
      MatchInfoText("Respawn Time",
          "${selectedGroup.matchOptions.respawnDuration} ${selectedGroup.matchOptions.respawnTimeType}"),
      MatchInfoText("Permitted Elimation Type",
          selectedGroup.matchOptions.eliminationType),
      MatchInfoText(
          "Off Limit Areas", selectedGroup.matchOptions.offLimitAreas),
      MatchInfoText("Safety Methods", selectedGroup.matchOptions.safetyMethods),
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
// final int currPlayers;
//  int currPlayers;
  final bool buttonState;
//  const LargeUserHomeButton({
  LargeUserHomeButton({
    required this.label,
    required this.color,
    required this.onPressed,
    //this.currPlayers = 2,
    required this.buttonState,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
//    print('curr plauers: ${currPlayers}');
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size.fromHeight(50),
        textStyle: TextStyle(fontSize: 25),
      ),
      //onPressed: (currPlayers < 2) ? null : onPressed,
      onPressed: (buttonState) ? onPressed : null,
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
