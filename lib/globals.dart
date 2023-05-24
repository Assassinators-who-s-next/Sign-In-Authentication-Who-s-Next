library whos_next.globals;

import 'dart:async';

import 'package:basic_auth/models/player_with_target.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'models/user_data.dart';
import 'models/match_options.dart';
import 'game_group.dart';

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

bool finishedLoadingUser = false;
StreamController finishedLoadingUserController = StreamController<bool>.broadcast();
Group selectedGroup = Group(
  "join or create a game to play",
  [],
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

UserData? currentTarget;

User? fireBaseUser;
