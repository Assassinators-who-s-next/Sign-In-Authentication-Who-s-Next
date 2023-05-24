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
String myName = "no_name";
bool finishedLoadingUser = false;
StreamController finishedLoadingUserController =
    StreamController<bool>.broadcast();
Group selectedGroup = Group(
  "join or create games to play",
  [],
  MatchOptions(
    -1,
    'Single',
    'Fixed',
    5,
    'Limited',
    60,
    'Area A',
    'Helmet',
  ),
  "",
  state: GroupState.notStarted

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
