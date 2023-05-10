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

final storage = FirebaseStorage.instance;

// sends

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

void createGame(BuildContext context, String? userID) async {
  String newGroupID = getRandomString(5);

  CollectionReference groupsRef =
      FirebaseFirestore.instance.collection('groups');

  // Check if the game already exists
  DocumentSnapshot gameSnapshot = await groupsRef.doc(newGroupID).get();
  if (gameSnapshot.exists) {
    // Handle error case where game already exists
    throw Exception('Game with ID $newGroupID already exists.');
  }

  //Map<String, dynamic> usersData = {"user_id": userID!, "points": 0};
  await groupsRef.doc(newGroupID).collection('players').doc(userID).set({
    'players': [
      {'user_id': userID, 'points': 0}
    ],
    // Add any other fields you want to initialize here
  });

  join_game(context, newGroupID, userID!);

  String my_name = userID;
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
