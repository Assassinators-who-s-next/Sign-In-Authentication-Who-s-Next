// ignore_for_file: deprecated_member_use

import 'package:whos_next/components/game_list_drawer.dart';
import 'package:whos_next/components/profile_picture.dart';
import 'package:whos_next/player.dart';
import 'package:whos_next/utils/popup_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whos_next/models/user_data.dart';
import 'package:whos_next/networking.dart';
import 'package:whos_next/pages/join_create_game_page.dart';
import 'package:whos_next/game_group.dart';
import 'package:whos_next/globals.dart' as globals;

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => UserHomeState();
}

class UserHomeState extends State<UserHome> {
  bool? isCheckedBox = false;
  bool notifyTarget = false;
  late Group selGroup;

  UserHomeState() {
    addGroupUpdateListener(updateGroupRef);
  }

  @override
  void dispose() {
    removeGroupUpdateListener(updateGroupRef);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selGroup = globals.selectedGroup;
  }

  void setSelectedGroup(Group group) async {
    globals.setSelectedGroup(group);
    updateGroupRef();
    globals.setFinishedLoadingState(false);
    await reloadSelectedGroup();
    globals.setFinishedLoadingState(true);
  }

  void updateGroupRef() {
    setState(() {
      selGroup = globals.selectedGroup;
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

    return globals.myGroups.isEmpty
        ? noGroupScreenContent(context)
        : StreamBuilder<GroupState>(
            stream: getGroupStateStream(selGroup.groupName),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              GroupState groupState = snapshot.data ?? GroupState.notStarted;

              return GameListDrawer(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                content: homeScreenContent(
                    context, screenWidth, screenHeight, groupState),
                onSelectGroup: (p0) => setSelectedGroup(p0),
              );
            });
  }

  Stream<GroupState> getGroupStateStream(String groupId) {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data != null) {
        final state = data['state'];
        if (state != null) {
          return GroupState.values[state];
        }
      }
      return GroupState.notStarted;
    });
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
                primary: const Color.fromARGB(255, 43, 167, 204),
                minimumSize: const Size(200, 50),
                textStyle: const TextStyle(fontSize: 25),
              ),
              onPressed: () => {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JoinCreatePage(),
                    )),
              },
              child: const Text("Join/Create"),
            ),
          ),
        ],
      ),
    );
  }

  Widget homeScreenContent(BuildContext context, double screenWidth,
      double screenHeight, GroupState currentState) {
    Widget screen = prematchScreen(); 

    if (currentState == GroupState.finished) {
      screen = postmatchScreen();
    } else if (currentState == GroupState.running) {
      screen = runningScreen(screenWidth, screenHeight, context);
    } else {
      screen = prematchScreen();
    }

    return Stack(children: [
      infoButton(context, screenWidth, screenHeight),
      screen,
    ]);
  }

  Stream<PlayerState> getPlayerStateStream(String groupId, String playerId) {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('players')
        .doc(playerId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data != null) {
        final state = data['state'];
        if (state != null) {
          return PlayerState.values[state];
        }
      }
      return PlayerState
          .alive;
    });
  }

  StreamBuilder<PlayerState> runningScreen(
      double screenWidth, double screenHeight, BuildContext context) {
    return StreamBuilder<PlayerState>(
        stream: getPlayerStateStream(globals.selectedGroup.groupName, globals.myUserData.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("running screen crashed(player state have some issue)");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          PlayerState playerState = snapshot.data ?? PlayerState.alive;

          if (playerState == PlayerState.preparingToDie) {
            return prepareToDieScreen(screenWidth, screenHeight);
          } else if (playerState == PlayerState.dead) {
            return deadScreen(screenWidth, screenHeight);
          }

          bool isDefaultPicture = globals.currentTarget!.imagePath == null ||
              globals.currentTarget!.imagePath == "";


          UserData targetData = UserData(
              description: globals.currentTarget!.description,
              email: "",
              frequentedLocations: globals.currentTarget!.frequentedLocations,
              imagePath: isDefaultPicture
                  ? "lib/images/placeHolderProfileImage.jpg"
                  : globals.currentTarget!.imagePath,
              name: globals.currentTarget!.name,
              pronouns: globals.currentTarget!.pronouns,
              uid: globals.currentTarget!.uid);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TargetName(username: targetData.name),
                      Text("(${targetData.pronouns})", style: const TextStyle(color: Colors.grey)),
                      
                    ]
                  ),
                ),

                const Padding(padding: EdgeInsetsDirectional.all(5)),
                 
                ProfilePicture(
                    radius: screenWidth * 0.40,
                    imagePath: targetData.imagePath!,
                    isNetworkPath: !isDefaultPicture,
                    onClicked: () => {}),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Frequented Locations: ${targetData.frequentedLocations}"),
                    Text("Insider Intelligence: ${targetData.description}"),
                  ],
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.all(40),
                  child: LargeUserHomeButton(
                      label: "Eliminate",
                      color: const Color.fromARGB(255, 238, 127, 119),
                      buttonState: true,
                      onPressed: () async {
                        beginElimination();
                      }),
                ),
              ],
            ),
          );
        });
  }
}


Future<void> beginElimination() async {
  Player player =
      globals.selectedGroup.players[globals.currentTarget!.uid]!;
  player.state = PlayerState.preparingToDie;
  player.eliminator = globals.myUserData.uid;
  setPlayerInGroup(globals.currentTarget!.uid, globals.selectedGroup.groupName, player);
}

Future<void> endElimination() async {
  Player player = globals.selectedGroup.players[globals.myUserData.uid]!; 
  player.state = PlayerState.dead;
  setPlayerInGroup(globals.myUserData.uid, globals.selectedGroup.groupName, player);
}

Future<void> backToAlive() async {
  Player player = globals.selectedGroup.players[globals.myUserData.uid]!;
  player.state = PlayerState.alive;
  setPlayerInGroup(globals.myUserData.uid, globals.selectedGroup.groupName, player);
}

Center deadScreen(double screenWidth, double screenHeight) {
  return Center(
    child: SizedBox(
      width: screenWidth,
      height: screenHeight / 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'You are eliminated.\n Please wait until the match is completed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontSize: 30,
              ),
            ),
          ),
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
              "You have been eliminated! Do you acknowledge this occurred?",
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
                  backgroundColor: const Color.fromARGB(255, 238, 127, 119),
                  minimumSize: Size(screenWidth * 0.25, screenHeight * 0.05),
                  textStyle: const TextStyle(fontSize: 25),
                ),
                onPressed: () async {
                  eliminatePlayer();
                },
                child: const Text("Yes"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 43, 167, 204),
                  minimumSize: Size(screenWidth * 0.25, screenHeight * 0.05),
                  textStyle: const TextStyle(fontSize: 25),
                ),
                onPressed: () async {
                  backToAlive();
                },
                child: const Text("No"),
              ),
            ],
          )
        ],
      ),
    ),
  );
}

StreamBuilder prematchScreen() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('groups')
        .doc(globals.selectedGroup.groupName)
        .collection('players')
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Center(
            child: Text('Error loading game ${globals.selectedGroup.groupName}'));
      } else if (snapshot.connectionState == ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsetsDirectional.all(20),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      bool enoughPlayers = false;
      if (snapshot.data!.size >= 2) {
        enoughPlayers = true;
      }
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text("Players In Match: ", style: TextStyle(fontSize: 30)),
        ),
        Text("${snapshot.data!.size}/${globals.selectedGroup.matchOptions.maxPlayers}",
            style: const TextStyle(fontSize: 25)),
        Padding(
          padding: const EdgeInsetsDirectional.all(40),
          child: LargeUserHomeButton(
            label: "Start match",
            color: const Color.fromARGB(255, 43, 167, 204),
            buttonState:
                enoughPlayers && globals.selectedGroup.groupHost == globals.myUserData.uid,
            onPressed: () async {
              await startGameOrRespawn();
              globals.selectedGroup.state = GroupState.running;
              updateGroupState(globals.selectedGroup);
            },
          ),
        )
      ]));
    },
  );
}

String getLastPlayerStandingImage() {
  Map<String, Player> playersList = globals.selectedGroup.players;

  String? lastPlayerImage = "";

  playersList.forEach((key, value) {
    if (value.state != PlayerState.dead) {
      if (value.userData!.imagePath == null ||
          value.userData!.imagePath == "") {
        return;
      }

      lastPlayerImage = value.userData!.imagePath;
      return;
    }
  });

  return lastPlayerImage ?? "";
}

String getLastPlayerStandingName() {
  Map<String, Player> playersList = globals.selectedGroup.players;

  String? lastPlayerName = "";

  playersList.forEach((key, value) {
    if (value.state != PlayerState.dead) {
      lastPlayerName = value.name;
      return;
    }
  });

  return lastPlayerName ?? "";
}

String getMaxPointsPlayerImage() {
  List playersList = globals.selectedGroup.players.values.toList();

  playersList.sort((a, b) => b.points.compareTo(a.points));

  Player maxPoints = playersList.first;

  String? maxPointsPlayerImage = "";

  if (maxPoints.userData == null ||
      maxPoints.userData!.imagePath == null ||
      maxPoints.userData!.imagePath == "") {
    return maxPointsPlayerImage;
  }

  maxPointsPlayerImage = maxPoints.userData!.imagePath;

  return maxPointsPlayerImage ?? "";
}

String getMaxPointsPlayerName() {
  List playersList = globals.selectedGroup.players.values.toList();

  playersList.sort((a, b) => b.points.compareTo(a.points));

  Player maxPoints = playersList.first;

  return maxPoints.name ?? "";
}

Center postmatchScreen() {
  String maxPointsPlayerName = getMaxPointsPlayerName();
  String maxPointsPlayerImage = getMaxPointsPlayerImage();

  String lastPlayerName = getLastPlayerStandingName();
  String lastPlayerImage = getLastPlayerStandingImage();

  return Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Padding(
        padding: EdgeInsets.all(20),
        child: Text("Match Finished!", style: TextStyle(fontSize: 30)),
      ),
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Last Standing",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Padding(padding: EdgeInsetsDirectional.all(5)),
            Text(lastPlayerName, style: const TextStyle(fontSize: 20)),
            const Padding(padding: EdgeInsetsDirectional.all(5)),
            ProfilePicture(
                radius: WidgetsBinding.instance.platformDispatcher.views.first
                        .physicalSize.width *
                    0.20,
                imagePath: lastPlayerImage == ""
                    ? "lib/images/placeHolderProfileImage.jpg"
                    : lastPlayerImage,
                isNetworkPath: lastPlayerImage != "",
                onClicked: () => {}),
            const Padding(padding: EdgeInsetsDirectional.all(15)),
            const Text("Most Eliminations",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Padding(padding: EdgeInsetsDirectional.all(5)),
            Text(maxPointsPlayerName, style: const TextStyle(fontSize: 20)),
            const Padding(padding: EdgeInsetsDirectional.all(5)),
            ProfilePicture(
                radius: WidgetsBinding.instance.platformDispatcher.views.first
                        .physicalSize.width *
                    0.20,
                imagePath: maxPointsPlayerImage == ""
                    ? "lib/images/placeHolderProfileImage.jpg"
                    : maxPointsPlayerImage,
                isNetworkPath: maxPointsPlayerImage != "",
                onClicked: () => {}),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsetsDirectional.all(40),
        child: LargeUserHomeButton(
          label: "Start a new match",
          color: const Color.fromARGB(255, 43, 167, 204),
          buttonState: globals.selectedGroup.groupHost == globals.myUserData.uid,
          onPressed: () => {
            globals.selectedGroup.state = GroupState.notStarted,
            updateGroupState(globals.selectedGroup),
          },
        ),
      ),
    ]),
  );
}

Container infoButton(
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
              title: const Text("Match Info: ",
                  style: TextStyle(
                      fontSize: 35, fontWeight: FontWeight.bold)),
              content: aboutPopupContent(),
              bottomWidgets: [
                closeButton(context),
              ],
              width: screenWidth * .9,
              height: screenHeight * .9,
            )
          },
          child: Icon(Icons.info, size: size),
        ),
      ),
    ),
  );
}

Widget aboutPopupContent() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      //MatchInfoText("Game Period",
      //    "${selectedGroup.matchOptions.totalGameTimeDuration} ${selectedGroup.matchOptions.totalGameTimeType}"),
      //MatchInfoText("Respawn Time",
      //    "${selectedGroup.matchOptions.respawnDuration} ${selectedGroup.matchOptions.respawnTimeType}"),
      matchInfoText("Permitted Elimation Type",
          globals.selectedGroup.matchOptions.eliminationType),
      matchInfoText(
          "Off Limit Areas", globals.selectedGroup.matchOptions.offLimitAreas),
      matchInfoText("Safety Methods", globals.selectedGroup.matchOptions.safetyMethods),
    ],
  );
}

Column matchInfoText(String label, String text) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("$label: ",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text(text),
      const SizedBox(
        height: 15,
      ),
    ],
  );
}

class LargeUserHomeButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool buttonState;
  const LargeUserHomeButton({
    required this.label,
    required this.color,
    required this.onPressed,
    required this.buttonState,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size.fromHeight(50),
        textStyle: const TextStyle(fontSize: 25),
      ),
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
      padding: const EdgeInsetsDirectional.all(5),
      child: Text('Target: $username',
          style: const TextStyle(fontSize: 30), textAlign: TextAlign.center),
    );
  }
}
