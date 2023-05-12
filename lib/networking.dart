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

void set_user_data(
    String userID, UserData userData, List<group> playerGroups) async {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  await usersRef.doc(userID).set({
    'user_id': userID,
    'points': 0,
    'name': userData.name,
    'email': userData.email,
    'pronouns': userData.pronouns,
    'description': userData.description,
    'frequentedLocations': userData.frequentedLocations,
    'playerGroups':
        playerGroups.map((curGroup) => curGroup.group_name).toList(),
  });
}

Future<group> loadGroup(String groupID) async {
  CollectionReference groupsRef =
      FirebaseFirestore.instance.collection('groups');

  DocumentSnapshot groupDocument = await groupsRef.doc(groupID).get();

  if (groupDocument.exists) {
    List<player> players = [];
    List<dynamic> playerDataList = groupDocument.get('players');

    for (var data in playerDataList) {
      players.add(player(data['user_id'], data['points'], null));
    }

    MatchOptions matchOptions = MatchOptions(
      groupDocument.get('eliminationType'),
      groupDocument.get('respawnTimeType'),
      groupDocument.get('respawnDuration'),
      groupDocument.get('totalGameTimeType'),
      groupDocument.get('totalGameTimeDuration'),
      groupDocument.get('offLimitAreas'),
      groupDocument.get('safetyMethods'),
    );

    return group(groupID, players, matchOptions);
  } else {
    throw Exception('Group does not exist');
  }
}

void load_my_user_data(String user_id) async {
  var my_user_data = null;
  try {
    my_user_data = await get_user_data(user_id);
  } catch (e) {
    print("Error loading my user data!");
    return;
  }
  var my_user_groups = await get_user_groups(user_id);

  List<group> myGroups = [];
  for (int i = 0; i < my_user_groups.length; i++) {
    String element = my_user_groups[i];
    myGroups[i] = await loadGroup(element);
  }

  globals.myUserData = my_user_data;
  globals.myName = my_user_data.name;
  globals.myGroups = myGroups;
  if (!myGroups.isEmpty) {
    globals.selectedGroup = myGroups[0];
  }
}

void login_custom(BuildContext context, String userName, String password) {
  load_my_user_data(userName);
}

void login_google(BuildContext context, String token) {
  load_my_user_data(token);
}

Future<void> login_apple(BuildContext context, String token) async {
  load_my_user_data(token);
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

  group newGroup = group(newGroupID, [player(userID!, 0, null)], matchOptions);

  bool isNotInGroup = globals.myGroups.isEmpty;
  globals.myGroups.add(newGroup);
  if (isNotInGroup) {
    globals.selectedGroup = newGroup;
  }
  set_user_data(userID, globals.myUserData, globals.myGroups);

  //join_game(context, newGroupID, userID!);
}

void join_game(BuildContext context, String game_code, String? userID,
    {int points = 0}) async {
  DocumentReference gameRef =
      FirebaseFirestore.instance.collection('groups').doc(game_code);

  try {
    // Add the new user to the game's "users" subcollection
    await gameRef
        .collection('players')
        .doc(userID)
        .set({'user_id': userID, 'points': points});
    print('User $userID added to game $game_code');

    var joinedGame = await loadGroup(game_code);

    bool isNotInGroup = globals.myGroups.isEmpty;
    globals.myGroups.add(joinedGame);
    if (isNotInGroup) {
      globals.selectedGroup = joinedGame;
    }
    set_user_data(userID!, globals.myUserData, globals.myGroups);
  } catch (e) {
    print('Error adding user to game: $e');
  }
}
