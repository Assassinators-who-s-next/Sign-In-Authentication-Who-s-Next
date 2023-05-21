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

Future<UserData?> get_user_data(String user_id) async {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  DocumentSnapshot userDocument = await usersRef.doc(user_id).get();

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
      uid: user_id,
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

Future<List<String>> get_user_groups(String user_id) async {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  DocumentSnapshot userDocument = await usersRef.doc(user_id).get();

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
        players.add(
            Player(userId, points, null, target_uid: "", state: playerState));
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

    return Group(groupID, players, matchOptions);
  } else {
    throw Exception('Group does not exist');
  }
}

Future<bool> load_my_user_data(String user_id) async {
  var my_user_data = null;
  try {
    my_user_data = await get_user_data(user_id);
  } catch (e) {
    print("Error loading my user data! \n" + e.toString());
    return false;
  }
  var my_user_groups = await get_user_groups(user_id);

  List<Group> myGroups = [];
  for (int i = 0; i < my_user_groups.length; i++) {
    String element = my_user_groups[i];
    try {
      myGroups.add(await loadGroup(element));
    } catch (e, stacktrace) {
      print('Error loading group: \"$element\": $e at: $stacktrace');
    }
  }

  globals.myUserData = my_user_data;
  print("Printing User data from load_my_user_data: ${globals.myUserData}");
  globals.myName = my_user_data.name;
  globals.myGroups = myGroups;

  if (!myGroups.isEmpty) {
    // this should instead remember locally what the last group was
    globals.selectedGroup = myGroups[0];
  }
  return true;
}

Future set_default_user_data(String token) async {
  UserData userData = UserData(
    uid: globals.fireBaseUser!.uid,
    imagePath: "",
    name: globals.fireBaseUser!.displayName!,
    email: globals.fireBaseUser!.email!,
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
    BuildContext context, String game_code, String? userID,
    {int points = 0}) async {
  DocumentReference gameRef =
      FirebaseFirestore.instance.collection('groups').doc(game_code);

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
      var joinedGame = await loadGroup(game_code);

      await gameRef
          .collection('players')
          .doc(userID)
          .set({'user_id': userID, 'points': points});
      print('User $userID added to game $game_code');

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

void start_game_or_respawn() {


  /* things to note

    - game state is only initialized for player who created game
    - previous game information shows if you log out and log back in with another account that isn't in that previous game
    - need to store target_uid for each player in groups on db
  */
  globals.selectedGroup.players.shuffle();
  print("Group len: ${globals.selectedGroup.players.length}");
  for (int i = 0; i < globals.selectedGroup.players.length; i++) {
    print(globals.selectedGroup.players[i].userID);
  }

  // asign targets
  for (int i = 0; i < globals.selectedGroup.players.length; i++) {
    print((i + 1) % globals.selectedGroup.players.length);
    //globals.selectedGroup.play
    
  }
}

Future logout(context) async {
  await FirebaseAuth.instance.signOut().then((value) => Navigator.of(context)
      .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AuthPage()),
          (route) => false));
}
