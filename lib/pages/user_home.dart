import 'dart:developer';

import 'package:basic_auth/components/game_list_drawer.dart';
import 'package:basic_auth/components/profile_picture.dart';
import 'package:basic_auth/globals.dart';
import 'package:basic_auth/models/match_options.dart';
import 'package:basic_auth/player.dart';
import 'package:basic_auth/utils/popup_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:basic_auth/models/user_data.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:basic_auth/networking.dart';
import 'package:basic_auth/pages/join_create_game_page.dart';
import 'package:basic_auth/image_upload.dart';

import '../game_group.dart';

class UserHome extends StatefulWidget {
  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  bool? isCheckedBox = false;
  bool notifyTarget = false;
  late Group selGroup;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selGroup = selectedGroup; //this might not get the state update as well
  }

  // I think you need this when you click different group
  void SetSelectedGroup(Group group) async {
    setSelectedGroup(group);
    setState(() {
      selGroup = selectedGroup;
    });
    SetFinishedLoadingState(false);
    await reloadSelectedGroup();
    SetFinishedLoadingState(true);
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
        : StreamBuilder<Group>(
            stream: getGroupStream(selGroup.group_name),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              PlayerState playerState =
                  snapshot.data!.players[myUserData.uid]!.state;
              print("This is player state");
              print(playerState);
              GroupState groupState = snapshot.data!.state;
              print("This is group state");
              print(groupState);

              return GameListDrawer(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                content: homeScreenContent(context, screenWidth, screenHeight,
                    groupState, playerState),
                onSelectGroup: (p0) => SetSelectedGroup(p0),
              );
            });
  }

  //listen to the whole group and get the group data
  //Although,
  Stream<Group> getGroupStream(String groupId) {
    print("stream happend!");
    Future<Group> group = Future.delayed((Duration(seconds: 2)), () => loadGroup(groupId));
    return Stream.fromFuture(group);
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

  Widget homeScreenContent(BuildContext context, double screenWidth,
      double screenHeight, GroupState currentState, PlayerState playerState) {
    Widget screen = prematchScreen(); //default screen that returns

    if (currentState == GroupState.finished) {
      // game finished state
      screen = postmatchScreen();
      print("going to finishedScreen switch statement");
    } else if (currentState == GroupState.running) {
      // game running state
      if (playerState == PlayerState.dead) {
        // player dead state
        screen = deadScreen(screenWidth, screenHeight);
        print("going to dead screen");
      } else if (playerState == PlayerState.preparingToDie) {
        screen = prepareToDieScreen(screenWidth, screenHeight);
        print("going to preparetodie screen");
      } else {
        screen = aliveScreen(screenWidth, screenHeight, context);
        print("going to alive screen");
      }
    } else {
      screen = prematchScreen();
      print("going to prematchScreen switch statement");
    }

    return Stack(children: [
      InfoButton(context, screenWidth, screenHeight),
      screen,
    ]);
  }

  Center aliveScreen(
      double screenWidth, double screenHeight, BuildContext context) {
    //UserData targetData = myUserData;
    //UserData targetData = UserPreferences.user;

    UserData targetData = UserData(
        description: currentTarget!.description,
        email: "",
        frequentedLocations: currentTarget!.frequentedLocations,
        imagePath:
            currentTarget!.imagePath == null || currentTarget!.imagePath == ""
                ? "lib/images/placeHolderProfileImage.jpg"
                : currentTarget!.imagePath,
        name: currentTarget!.name,
        pronouns: currentTarget!.pronouns,
        uid: currentTarget!.uid);

    print("\n\n\n TARGET DATA ALIVE SCREEN: ${targetData.name}\n\n\n");

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TargetName(username: targetData.name),
          ProfilePicture(
              radius: screenWidth * .40,
              imagePath: targetData.imagePath!,
              //imagePath: targetData.imagePath ?? UserPreferences.placeholderImagePath,
              isNetworkPath:
                  myUserData.imagePath != null && myUserData.imagePath != "",
              onClicked: () => print("clicked elimation target")),
          Text("freq locations: ${targetData.frequentedLocations}"),
          Text("Descrpt: ${targetData.description}"),
          Padding(
            padding: const EdgeInsetsDirectional.all(40),
            child: LargeUserHomeButton(
                label: "Eliminate",
                color: Color.fromARGB(255, 238, 127, 119),
                buttonState: true,
                onPressed: () async {
                  Player playerSelf = getSelf()!;
                  Player playerTarget =
                      await getPlayerInGroup(selectedGroup, currentTarget!.uid);

                  playerSelf.target =
                      await getTargetUID(selectedGroup, myUserData.uid);
                  playerTarget.target =
                      await getTargetUID(selectedGroup, currentTarget!.uid);

                  SetSelectedGroup(selectedGroup);

                  print("\n\n playerSelf: $playerSelf");
                  print("\n\n playerTarget: $playerTarget");

                  // eliminate target
                  await eliminatePlayer(
                      context, playerSelf, playerTarget, selectedGroup);

                  setSelectedGroup(selectedGroup);

                  beginElimination();

                  //selectedGroup.state = GroupState.finished;
                  //update_group_state(selectedGroup);

                  //await eliminatePlayer(context, playerSelf, , selectedGroup);

                  //eliminateNoti(targetData, context, screenWidth, screenHeight);
                  /*
                  print(
                      "In user_home eliminationScreen onPressed, getting target uid: ${selectedGroup.get(currentTarget!.uid)}");
                  Player playerForTesting =
                      await getPlayerInGroup(selectedGroup, currentTarget!.uid);
                  print(
                      "\n\n\nIn user_home eliminationScreen onPressed, getSelf()!.name: ${getSelf()!.name}");
                  print(
                      "In user_home eliminationScreen onPressed, getPlayerInGroup: ${playerForTesting}");
                  print(
                      "In user_home eliminationScreen onPressed, selectedGroup.groupName: ${selectedGroup.group_name}\n\n\n");

                  await eliminatePlayer(
                      context,
                      getSelf()!,
                      await getPlayerInGroup(selectedGroup, getSelf()!.target),
                      selectedGroup);
                  print(
                      "\n\ngetTargetUID: ${await getTargetUID(selectedGroup, currentTarget!.uid)}\n\n");
                  */
                  //Player targetPlayer = await getPlayerInGroup(selectedGroup, );
                  //await eliminatePlayer(context, getSelf()!, );

                  // delete later for testing
                  // delete later for testing

                  // eliminate target

                  //selectedGroup.players[currentTarget]!.state = PlayerState.dead;

                  // set their state to currently dead and waiting next game
                }),
          ),
        ],
      ),
    );
  }

  //basically update the state of the playerstate
  //and upload it to the database
  void beginElimination() {
    Player player =
        selectedGroup.players[currentTarget!.uid]!; //HOPE IT IS DEEP COPY
    player.state = PlayerState.preparingToDie;
    print("eliminator state now changed to " + player.state.index.toString());
    setPlayerInGroup(myUserData.uid, selectedGroup.group_name, player);
  }

  void endElimination() {
    Player player =
        selectedGroup.players[myUserData.uid]!; //HOPE IT IS DEEP COPY
    player.state = PlayerState.dead;
    setPlayerInGroup(myUserData.uid, selectedGroup.group_name, player);
  }

  void backToAlive() {
    Player player =
        selectedGroup.players[myUserData.uid]!; //HOPE IT IS DEEP COPY
    player.state = PlayerState.alive;
    setPlayerInGroup(myUserData.uid, selectedGroup.group_name, player);
  }

  /* Create a function deadScreen() where it returns the widget that has the component of a big header text with red color
   that generates "you're dead, wait for winner comes up" with the gray background */
  Center deadScreen(double screenWidth, double screenHeight) {
    return Center(
      child: SizedBox(
        width: screenWidth,
        height: screenHeight / 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'You are eliminated.\n Please wait until winner announce.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 30,
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.all(20),
                child: LargeUserHomeButton(
                    label: "Debug(go to finished screen)",
                    color: Color.fromARGB(255, 43, 167, 204),
                    buttonState: true,
                    onPressed: () => {
                          selectedGroup.state = GroupState.finished,
                          update_group_state(selectedGroup),
                        }))
          ],
        ),
      ),
    );
  }

  Center prepareToDieScreen(double screenWidth, double screenHeight) {
    return Center(
      child: SizedBox(
        width: screenWidth,
        height: screenHeight / 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'You are about to get eliminated by annonymous player. Is this you?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 30,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 238, 127, 119),
                    minimumSize: Size(screenWidth * 0.25, screenHeight * 0.05),
                    textStyle: TextStyle(fontSize: 25),
                  ),
                  onPressed: () => {
                    //put target have eliminate notification page appear on their hand
                    endElimination(),
                    print("eliminated done")
                  },
                  child: Text("Yes"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 43, 167, 204),
                    minimumSize: Size(screenWidth * 0.25, screenHeight * 0.05),
                    textStyle: TextStyle(fontSize: 25),
                  ),
                  onPressed: () =>
                      {backToAlive(), print("eliminated canceled")},
                  child: Text("No"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

//Center prematchScreen(double screenWidth) {
  StreamBuilder prematchScreen() {
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
        return Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text("Players In Match: ", style: TextStyle(fontSize: 30)),
          ),
          Text(
              "${snapshot.data!.size}/${selectedGroup.matchOptions.maxPlayers}",
              style: const TextStyle(fontSize: 25)),
          Padding(
            padding: const EdgeInsetsDirectional.all(40),
            child: LargeUserHomeButton(
              label: "Start match",
              color: const Color.fromARGB(255, 43, 167, 204),
              //currPlayers: snapshot.data!.size,
              buttonState: enoughPlayers,
              onPressed: () async {
                print("pressed start match button");
                await startGameOrRespawn();
                selectedGroup.state = GroupState.running;
                update_group_state(selectedGroup);
              },
            ),
          )
        ]));
      },
    );
  }

  Center postmatchScreen() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Text("Match Finished!", style: TextStyle(fontSize: 30)),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Text("Winner: ", style: TextStyle(fontSize: 20)),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.all(40),
          child: LargeUserHomeButton(
            label: "Start a new match",
            color: const Color.fromARGB(255, 43, 167, 204),
            buttonState: true,
            onPressed: () => {
              selectedGroup.state = GroupState.notStarted,
              update_group_state(selectedGroup),
            },
          ),
        ),
      ]),
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
        //MatchInfoText("Game Period",
        //    "${selectedGroup.matchOptions.totalGameTimeDuration} ${selectedGroup.matchOptions.totalGameTimeType}"),
        //MatchInfoText("Respawn Time",
        //    "${selectedGroup.matchOptions.respawnDuration} ${selectedGroup.matchOptions.respawnTimeType}"),
        MatchInfoText("Permitted Elimation Type",
            selectedGroup.matchOptions.eliminationType),
        MatchInfoText(
            "Off Limit Areas", selectedGroup.matchOptions.offLimitAreas),
        MatchInfoText(
            "Safety Methods", selectedGroup.matchOptions.safetyMethods),
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
