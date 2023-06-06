library whos_next.globals;

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
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

void setFinishedLoadingState(bool state) {
  finishedLoadingUser = state;
  finishedLoadingUserController.add(state);
}

Player? getSelf() => selectedGroup.players[myUserData.uid];

bool finishedLoadingUser = false;
StreamController finishedLoadingUserController =
    StreamController<bool>.broadcast();
bool hasSelectedGroup = false;
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
  DateTime.utc(1989, 11, 9),
  DateTime.utc(1989, 11, 9),
  state: GroupState.notStarted,
);
List<Group> myGroups = [];

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

void setSelectedGroup(Group group) {
  stopListeningToGroupChanges();
  hasSelectedGroup = true;
  selectedGroup = group;
  listenToGroupChanges(group.groupName);
}
