library whos_next.globals;

import 'dart:async';

import 'package:basic_auth/models/player_with_target.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:basic_auth/player.dart';
import 'models/user_data.dart';
import 'models/match_options.dart';
import 'game_group.dart';
import 'networking.dart';

UserData myUserData = UserData(
  uid: "",
  imagePath: "",
  name: "",
  email: "",
  pronouns: "",
  description: "",
  frequentedLocations: "",
);

void SetFinishedLoadingState(bool state) {
  finishedLoadingUser = state;
  finishedLoadingUserController.add(state);
}

Player? getSelf() => selectedGroup.players[myUserData.uid];

bool finishedLoadingUser = false;
StreamController finishedLoadingUserController =
    StreamController<bool>.broadcast();
bool hasSelectedGroup = false;
//current group
Group selectedGroup = Group(
  "join or create a game to play",
  {},
  MatchOptions(
    -1,
    '',
    '',
    -1,
    '',
    -1,
    '',
    '',
  ),
  "",
  new DateTime.utc(1989, 11, 9),
  new DateTime.utc(1989, 11, 9),
  state: GroupState.notStarted,
);
//    GameState.gameWaiting.name);
List<Group> myGroups = [];

/*
TargetInfo currentTarget = TargetInfo(
  targetUID: "",
  targetName: "",
  targetImage: "",
  targetDescription: "",
  targetPronouns: "",
  targetFrequentedLocations: "",
);
*/

UserData? currentTarget = UserData(
  uid: "",
  imagePath: "",
  name: "",
  email: "",
  pronouns: "",
  description: "",
  frequentedLocations: "",
);


User? fireBaseUser;

Future<void> setSelectedGroup(Group group) async {
  stopListeningToGroupChanges();
  hasSelectedGroup = true;
  selectedGroup = group; //assign new group to our global group

  //hard to
  ListenToGroupChanges(group.group_name);

  currentTarget = await get_user_data(await get_curr_target_uid(playerUID: myUserData.uid, groupCode: selectedGroup.group_name));
}
