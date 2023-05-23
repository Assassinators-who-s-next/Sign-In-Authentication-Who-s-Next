import 'package:basic_auth/pages/join_create_game_page.dart';
import 'package:basic_auth/player.dart';
import 'package:flutter/material.dart';
import 'models/join_game_results.dart';
import 'pages/home_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'utils/random_string_generator.dart';
import 'game_group.dart';
import 'globals.dart' as globals;
import 'models/match_options.dart';
import 'models/user_data.dart';
import 'models/player_with_target.dart';
import 'auth.dart';

final storage = FirebaseStorage.instance;

Future<UserData?> get_user_data(String userId) async {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  DocumentSnapshot userDocument = await usersRef.doc(userId).get();

  if (userDocument.exists) {
    // Extract field values from the document snapshot
    String? imagePath = userDocument.get('imagePath');
    String name = userDocument.get('name');
    String email = userDocument.get('email');
    String pronouns = userDocument.get('pronouns');
    String description = userDocument.get('description');
    String frequentedLocations = userDocument.get('frequentedLocations');

    // Create a UserData object with the extracted field values
    UserData userData = UserData(
      uid: userId,
      imagePath: imagePath,
      name: name,
      email: email,
      pronouns: pronouns,
      description: description,
      frequentedLocations: frequentedLocations,
    );

    return userData;
  } else {
    throw Exception('Document does not exist');
    // or
    // return null;
  }
}

Future<List<String>> get_user_groups(String userId) async {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  DocumentSnapshot userDocument = await usersRef.doc(userId).get();

  if (userDocument.exists) {
    List<String> playerGroups =
        List<String>.from(userDocument.get('playerGroups') ?? []);

    return playerGroups;
  } else {
    throw Exception('Document does not exist');
    // or
    //return null;
  }
}

Future set_user_data(
    String userID, UserData userData, List<Group> playerGroups) async {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  print("set_user_data(" + userID + ", " + userData.name + ")");

  await usersRef.doc(userID).set({
    'user_id': userID,
    'points': 0,
    'name': userData.name,
    'email': userData.email,
    'imagePath': userData.imagePath,
    'pronouns': userData.pronouns,
    'description': userData.description,
    'frequentedLocations': userData.frequentedLocations,
    'playerGroups':
        playerGroups.map((curGroup) => curGroup.group_name).toList(),
  });
}

void applyName(List<Player> players) async {
  for (int i = 0; i < players.length; i++) {
    String element = players[i].userID;
    try {
      UserData? userData = await get_user_data(element);
      players[i].name = userData!.name;
    } catch (e, stacktrace) {
      print("Error loading player name! \n" +
          e.toString() +
          "\n" +
          stacktrace.toString());
    }
  }
}

Future<Group> loadGroup(String groupID) async {
  CollectionReference groupsRef =
      FirebaseFirestore.instance.collection('groups');

  DocumentSnapshot groupDocument = await groupsRef.doc(groupID).get();

  print("Loading group: " + groupID);
  if (groupDocument.exists) {
    List<Player> players = [];
    //List<dynamic> playerDataList = await groupDocument.get('players');
    //List<dynamic> playerDataList = await groupsRef.collection(groupID).get('players');
    //await groupsRef.doc(groupID).collection('players').get();

    QuerySnapshot playerSnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupID)
        .collection('players')
        .get();
    List<dynamic> playerDataList =
        playerSnapshot.docs.map((doc) => doc.data()).toList();

    if (!playerDataList.isEmpty) {
      for (var data in playerDataList) {
        String userId =
            data['user_id'] ?? ''; // Use an empty string if the value is null
        int points = data['points'] ?? 0; // Use 0 if the value is null
        PlayerState playerState = PlayerState.values[data['state'] ?? 0];
        String targetUID = data['target'] ?? "";
        players.add(Player(userId, points, null,
            state: playerState, target: targetUID));
      }
    }

    MatchOptions matchOptions = MatchOptions(
      groupDocument.get('maxPlayers'),
      groupDocument.get('eliminationType'),
      groupDocument.get('respawnTimeType'),
      groupDocument.get('respawnDuration'),
      groupDocument.get('totalGameTimeType'),
      groupDocument.get('totalGameTimeDuration'),
      groupDocument.get('offLimitAreas'),
      groupDocument.get('safetyMethods'),
    );

    int stateIndex = 0;
    Map<String, dynamic>? data = groupDocument.data() as Map<String, dynamic>?;
    if (data != null && data.containsKey('state')) {
      stateIndex = data['state'];
    } else {
      stateIndex = GroupState.notStarted.index;
    }
    GroupState state = GroupState.values[stateIndex];

    return Group(groupID, players, matchOptions, state: state);
  } else {
    throw Exception('Group does not exist');
  }
}

Future<bool> load_my_user_data(String userId) async {
  var myUserData = null;
  try {
    myUserData = await get_user_data(userId);
  } catch (e) {
    print("Error loading my user data! \n" + e.toString());
    return false;
  }
  var myUserGroups = await get_user_groups(userId);

  List<Group> myGroups = [];
  for (int i = 0; i < myUserGroups.length; i++) {
    String element = myUserGroups[i];
    try {
      myGroups.add(await loadGroup(element));
    } catch (e, stacktrace) {
      print('Error loading group: \"$element\": $e at: $stacktrace');
    }
  }

  globals.myUserData = myUserData;
  print("Printing User data from load_my_user_data: ${globals.myUserData}");
  globals.myName = myUserData.name;
  globals.myGroups = myGroups;

  if (!myGroups.isEmpty) {
    // this should instead remember locally what the last group was
    globals.selectedGroup = myGroups[0];
  }
  return true;
}

Future set_default_user_data(String token) async {
  UserData userData = UserData(
    uid: globals.fireBaseUser?.uid ?? 'default_uid',
    imagePath: "",
    name: globals.fireBaseUser?.displayName! ?? 'default_name',
    email: globals.fireBaseUser?.email! ?? 'default_email',
    pronouns: "",
    description: "",
    frequentedLocations: "",
  );
  List<Group> playerGroups = [];
  await set_user_data(token, userData, playerGroups);

  globals.myUserData = userData;
  globals.myName = userData.name;
  globals.myGroups = playerGroups;
}

void login_custom(
    BuildContext context, String userName, String password) async {
  bool success = await load_my_user_data(userName);
  //if (!sucess) set_default_user_data(userName);
}

Future login_google(BuildContext context, String email, String token) async {
  bool success = await load_my_user_data(token);
  if (!success) {
    await set_default_user_data(token);
  }
}

Future<void> login_apple(BuildContext context, String token) async {
  bool success = await load_my_user_data(token);
  if (!success) set_default_user_data(token);
}

Future<void> setPlayerInGroup(
    String userID, String newGroupID, Player player) async {
  CollectionReference groupsRef =
      FirebaseFirestore.instance.collection('groups');

  print(
      'in setPlayerInGroup\nplayer id: ${player.userID}\nplayer points: ${player.points}\nplayer state: ${player.state.index}');

  await groupsRef.doc(newGroupID).collection('players').doc(userID).set({
    'user_id': player.userID,
    'points': player.points,
    'state': player.state.index,
    'target': player.target,
  });

  print('finished setting player in group');

  /*
  await groupsRef.doc(newGroupID).collection('players').doc(userID).set({
    'players': [
      {'user_id': userID, 'points': 0, 'state': (PlayerState.alive)}
    ],
    // Add any other fields you want to initialize here
  });
  */
}

Future<Player?> getUser({required String targetUID}) async {
  var db = FirebaseFirestore.instance;

  final docRef = db.collection("users").doc(targetUID);

  docRef.get().then(
    (DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      print(data);
    },
    onError: (e) => print("Error getting document: $e"),
  );

  return null;
}

Future<Group> createGame(
    BuildContext context, String? userID, MatchOptions matchOptions) async {
  String newGroupID = getRandomString(5);

  CollectionReference groupsRef =
      FirebaseFirestore.instance.collection('groups');

  // Check if the game already exists
  DocumentSnapshot gameSnapshot = await groupsRef.doc(newGroupID).get();
  if (gameSnapshot.exists) {
    // Handle error case where game already exists
    throw Exception('Game with ID $newGroupID already exists.');
  }

  await groupsRef.doc(newGroupID).set({
    'maxPlayers': matchOptions.maxPlayers,
    'eliminationType': matchOptions.eliminationType,
    'respawnTimeType': matchOptions.respawnTimeType,
    'respawnDuration': matchOptions.respawnDuration,
    'totalGameTimeType': matchOptions.totalGameTimeType,
    'totalGameTimeDuration': matchOptions.totalGameTimeDuration,
    'offLimitAreas': matchOptions.offLimitAreas,
    'safetyMethods': matchOptions.safetyMethods,
    'state': GroupState.notStarted.index,
  });

  //Map<String, dynamic> usersData = {"user_id": userID!, "points": 0};
  await setPlayerInGroup(userID!, newGroupID, Player(userID, 0, null));

  print('User $userID created new game: $newGroupID');

  Group newGroup = Group(newGroupID, [Player(userID, 0, null)], matchOptions);

  final snapshot = await FirebaseFirestore.instance
      .collection('group')
      .doc(newGroupID)
      .collection('players')
      .get();
  if (snapshot.size == 0) {
    print('no players collection to be found');
  } else {
    print('there is a player collection');
  }

  print('num plyaers in newly created group: ${newGroup.players.length}');

  bool isNotInGroup = globals.myGroups.isEmpty;
  globals.myGroups.add(newGroup);
  if (isNotInGroup) {
    globals.selectedGroup = newGroup;
  }
  set_user_data(userID, globals.myUserData, globals.myGroups);

  return newGroup;

  //join_game(context, newGroupID, userID!);
}

Future<JoinGameResults> join_game(
    BuildContext context, String gameCode, String? userID,
    {int points = 0}) async {
  DocumentReference gameRef =
      FirebaseFirestore.instance.collection('groups').doc(gameCode);

  try {
    // Add the new user to the game's "users" subcollection

    // Check if the game already exists
    DocumentSnapshot gameSnapshot =
        await gameRef.collection('players').doc(userID).get();
    if (gameSnapshot.exists) {
      // Handle error case where game already exists
      //throw Exception('Game with ID $game_code already contains a player with ID: $userID');
      return JoinGameResults(false, 'You are already a member of this game.');
    }
    try {
      var joinedGame = await loadGroup(gameCode);

      await gameRef
          .collection('players')
          .doc(userID)
          .set({'user_id': userID, 'points': points});
      print('User $userID added to game $gameCode');

      bool isNotInGroup = globals.myGroups.isEmpty;
      globals.myGroups.add(joinedGame);
      if (isNotInGroup) {
        globals.selectedGroup = joinedGame;
      }
      set_user_data(userID!, globals.myUserData, globals.myGroups);
      return JoinGameResults(true);
    } catch (e) {
      return JoinGameResults(false, "Game Not Found");
    }
  } catch (e, stacktrace) {
    print('Error adding user to game: $e');
    return JoinGameResults(false, "Unexpected Error");
  }
}

void update_user(BuildContext context, String whatToChange, String changeTo) {
  var db = FirebaseFirestore.instance;
  final nameRef = db.collection("users").doc(globals.myUserData.uid);
  nameRef.update({whatToChange: changeTo}).then(
      (value) => print("DocumentSnapshot successfully updated!"),
      onError: (e) => print("Error updating document $e"));
}

class DatabaseReference {}

void startGameOrRespawn() async {
  /* things to note

    - game state is only initialized for player who created game
    - previous game information shows if you log out and log back in with another account that isn't in that previous game 
    - need to store target_uid for each player in groups on db (CHECK)
  */

  globals.selectedGroup.players.shuffle();

  // asign targets
  var groupSize = globals.selectedGroup.players.length;

  for (int i = 0; i < groupSize; i++) {
    globals.selectedGroup.players[i].target =
        globals.selectedGroup.players[(i + 1) % groupSize].userID;
    setPlayerInGroup(globals.selectedGroup.players[i].userID,
        globals.selectedGroup.group_name, globals.selectedGroup.players[i]);

    if (globals.selectedGroup.players[i].userID == globals.myUserData.uid) {
      await set_curr_target(targetUID: globals.selectedGroup.players[i].target!);
      print("current target: ${globals.currentTarget!.uid}");

    }
  }
  //for (int i = 0; i < groupSize; i++) {}
}

Future<void> set_curr_target({required String targetUID}) async {
  globals.currentTarget = await get_user_data(targetUID);
}

Future logout(context) async {
  await FirebaseAuth.instance.signOut().then((value) => Navigator.of(context)
      .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AuthPage()),
          (route) => false));
}
