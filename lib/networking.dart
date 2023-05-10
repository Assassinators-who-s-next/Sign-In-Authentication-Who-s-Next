import 'package:basic_auth/pages/join_create_game_page.dart';
import 'package:basic_auth/player.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'utils/random_string_generator.dart';
import 'game_group.dart';
import 'globals.dart' as globals;
import 'models/match_options.dart';
import 'models/user_data.dart';

final storage = FirebaseStorage.instance;

// sends

Future<UserData> get_user_data(String user_id) async {
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

void set_user_data(String userID, UserData userData) async {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  await usersRef.doc(userID).set({
    'user_id': userID,
    'points': 0,
    'name': userData.name,
    'email': userData.email,
    'pronouns': userData.pronouns,
    'description': userData.description,
    'frequentedLocations': userData.frequentedLocations
  }

      // Add any other fields you want to initialize here
      );
}

void login_custom(BuildContext context, String userName, String password) {
  String my_name = "temp_user";
  List<player> players = [
    player("p_one", 1),
    player("p_two", 2),
    player("p_three", 3),
    player("p_four", 4)
  ];
  List<group> groups = [group("game_one", players)];
  List<group> empty_groups = [];

  load_responce(context, my_name, empty_groups);
}

void login_google(BuildContext context, String token) {
  String my_name = "temp_user_google";
  List<player> players = [
    player("p_one", 1),
    player("p_two", 2),
    player("p_three", 3),
    player("p_four", 4)
  ];
  List<group> groups = [group("game_one", players)];
  List<group> empty_groups = [];

  load_responce(context, my_name, empty_groups);
}

Future<void> login_apple(BuildContext context, String token) async {
  String my_name = "temp_user_apple";
  List<player> players = [
    player("p_one", 1),
    player("p_two", 2),
    player("p_three", 3),
    player("p_four", 4)
  ];
  List<group> groups = [group("game_one", players)];
  List<group> empty_groups = [];

  load_responce(context, my_name, empty_groups);
}

void createGame(
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

  groupsRef.doc(newGroupID).set({
    'eliminationType': matchOptions.eliminationType,
    'respawnTimeType': matchOptions.respawnTimeType,
    'respawnDuration': matchOptions.respawnDuration,
    'totalGameTimeType': matchOptions.totalGameTimeType,
    'totalGameTimeDuration': matchOptions.totalGameTimeDuration,
    'offLimitAreas': matchOptions.offLimitAreas,
    'safetyMethods': matchOptions.safetyMethods,
  });

  //Map<String, dynamic> usersData = {"user_id": userID!, "points": 0};
  await groupsRef.doc(newGroupID).collection('players').doc(userID).set({
    'players': [
      {'user_id': userID, 'points': 0}
    ],
    // Add any other fields you want to initialize here
  });

  print('User $userID created new game: $newGroupID');

  //join_game(context, newGroupID, userID!);

  String my_name = userID!;
  List<player> players = [
    player(userID, 1),
  ];
  List<group> groups = [group(newGroupID, players)];

  load_responce(context, my_name, groups);
}

void join_game(BuildContext context, String game_code, String? userID,
    {int points = 0}) {
  DocumentReference gameRef =
      FirebaseFirestore.instance.collection('groups').doc(game_code);

  try {
    // Add the new user to the game's "users" subcollection
    gameRef
        .collection('players')
        .doc(userID)
        .set({'user_id': userID, 'points': points});
    print('User $userID added to game $game_code');
  } catch (e) {
    print('Error adding user to game: $e');
  }

  //load_responce(context, my_name, groups);
}

// responces

// call this when the server responds with a list of groups
load_responce(BuildContext context, String my_name, List<group> groups) {
  if (groups.isEmpty) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => JoinCreatePage()),
    // );
  } else {
    globals.myName = my_name;
    globals.myGroups = groups;
    globals.selectedGroup = groups[0];

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => HomePage()),
    // );
  }
}
