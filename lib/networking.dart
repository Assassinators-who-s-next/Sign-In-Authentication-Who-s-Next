import 'package:basic_auth/image_upload.dart';
import 'package:basic_auth/player.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'models/join_game_results.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'utils/random_string_generator.dart';
import 'game_group.dart';
import 'models/match_options.dart';
import 'models/user_data.dart';
import 'auth.dart';
import 'globals.dart' as globals;

// to check current platform
// source: https://stackoverflow.com/questions/71249485/flutter-web-is-giving-error-about-unsupported-operation-platform-operatingsyst
import 'package:flutter/foundation.dart';

final storage = FirebaseStorage.instance;

final List<Function> groupUpdateListeners = [];

void addGroupUpdateListener(Function listener) {
  groupUpdateListeners.add(listener);
}

void removeGroupUpdateListener(Function listener) {
  groupUpdateListeners.remove(listener);
}

void triggerGroupUpdateEvent() {
  for (var listener in groupUpdateListeners) {
    listener();
  }
}

void refresh() async {
  globals.setFinishedLoadingState(false);
  await reloadSelectedGroup();
  globals.myUserData.imagePath =
      await ProfilePage.retrieveImage(globals.myUserData);
  globals.setFinishedLoadingState(true);
}

Future<UserData?> getUserData(String userId) async {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  DocumentSnapshot userDocument = await usersRef.doc(userId).get();

  if (userDocument.exists) {
    String? imagePath = userDocument.get('imagePath');
    String name = userDocument.get('name');
    String email = userDocument.get('email');
    String pronouns = userDocument.get('pronouns');
    String description = userDocument.get('description');
    String frequentedLocations = userDocument.get('frequentedLocations');

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
  }
}

Future<List<String>> getUserGroups(String userId) async {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  DocumentSnapshot userDocument = await usersRef.doc(userId).get();

  if (userDocument.exists) {
    List<String> playerGroups =
        List<String>.from(userDocument.get('playerGroups') ?? []);

    return playerGroups;
  } else {
    throw Exception('Document does not exist'); 
  }
}

Future setUserData(
    String userID, UserData userData, List<Group> playerGroups) async {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
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
        playerGroups.map((curGroup) => curGroup.groupName).toList(),
  });
}

Future<void> reloadSelectedGroup() async {
  if (!globals.hasSelectedGroup) return;

  String groupID = globals.selectedGroup.groupName;
  Group fetchedGroup = await loadGroup(groupID);
  globals.selectedGroup = fetchedGroup;

  for (int i = 0; i < globals.myGroups.length; i++) {
    if (globals.myGroups[i].groupName == groupID) {
      globals.myGroups[i] = fetchedGroup;
    }
  }

  await loadPlayerNamesFromList(globals.selectedGroup.players.values.toList());

  if (globals.selectedGroup.state == GroupState.running) {
    await setCurrTarget(globals.getSelf()!.target);
  }
}

Future<void> loadPlayerNamesFromList(List<Player> players) async {
  var userDataGetters = <Future<UserData?>>[];
  for (int i = 0; i < players.length; i++) {
    Future<UserData?> userDataGetter = getUserData(players[i].userID);
    userDataGetters.add(userDataGetter);
  }
  List<UserData?> userDatas = await Future.wait(userDataGetters);

  for (int i = 0; i < userDatas.length; i++) {
    UserData? userData = userDatas[i];
    try {
      players[i].userData = userData;
      players[i].name = userData!.name;

      await updatePlayer(players[i].userID, players[i].name);
    } catch (e) {
      print("failed to load user data");
    }
  } 
}

Future<Group> loadGroup(String groupID) async {
  CollectionReference groupsRef =
      FirebaseFirestore.instance.collection('groups');

  DocumentSnapshot groupDocument = await groupsRef.doc(groupID).get();

  if (groupDocument.exists) {
    Map<String, Player> players = {};

    QuerySnapshot playerSnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupID)
        .collection('players')
        .get();
    List<dynamic> playerDataList =
        playerSnapshot.docs.map((doc) => doc.data()).toList();

    if (playerDataList.isNotEmpty) {
      for (var data in playerDataList) {
        String userId =
            data['user_id'] ?? ''; 
        int points = data['points'] ?? 0; 
        PlayerState playerState = PlayerState.values[data['state'] ?? 0];
        String targetUID = data['target'] ?? "";
        String? eliminatedBy = data['eliminatedBy'];
        players[userId] = Player(userId, points, null,
            state: playerState, target: targetUID, eliminator: eliminatedBy);
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

    String groupHost = "";
    try {
      groupHost = groupDocument.get('host');
    } catch (e) {}

    DateTime timeStarted = DateTime.utc(1989, 11, 9);
    try {
      timeStarted = groupDocument.get('timeStarted');
    } catch (e) {}

    DateTime timeEnding = DateTime.utc(1989, 11, 9);
    try {
      timeEnding = groupDocument.get('timeEnding');
    } catch (e) {}

    return Group(
        groupID, players, matchOptions, groupHost, timeStarted, timeEnding,
        state: state);
  } else {
    throw Exception('Group does not exist');
  }
}

Future<bool> loadMyUserData(String userId) async {
  UserData? myUserData;
  try {
    myUserData = await getUserData(userId);
  } catch (e) {
    print("Error loading my user data! \n" + e.toString());
    return false;
  }
  var myUserGroups = await getUserGroups(userId);

  List<Group> myGroups = [];
  for (int i = 0; i < myUserGroups.length; i++) {
    String element = myUserGroups[i];
    try {
      myGroups.add(await loadGroup(element));
    } catch (e, stacktrace) {
      print('Error loading group: \"$element\": $e at: $stacktrace');
    }
  }

  globals.myUserData = myUserData!;
  globals.myGroups = myGroups;

  globals.myUserData.imagePath =
      await ProfilePage.retrieveImage(globals.myUserData);

  if (myGroups.isNotEmpty) {
    globals.setSelectedGroup(myGroups[0]);
    listenToGroupChanges(globals.selectedGroup.groupName);
    await reloadSelectedGroup();
  }
  return true;
}

Future setDefaultUserData(String token) async {
  String? firstName = globals.fireBaseUser?.displayName!.split(' ')[0];

  var firstNameLength = firstName?.length ?? 0;

  if (firstNameLength > 26) {
    firstName = firstName!.substring(0, 26);
  }

  UserData userData = UserData(
    uid: globals.fireBaseUser?.uid ?? 'default_uid',
    imagePath: "",
    name: firstName ?? 'default_name',
    email: globals.fireBaseUser?.email! ?? 'default_email',
    pronouns: "",
    description: "",
    frequentedLocations: "",
  );
  List<Group> playerGroups = [];
  await setUserData(token, userData, playerGroups);

  globals.myUserData = userData;
  globals.myGroups = playerGroups;
}

void loginCustom(
    BuildContext context, String userName, String password) async {
  await loadMyUserData(userName);
}

Future loginGoogle(BuildContext context, String email, String token) async {
  bool success = await loadMyUserData(token);
  if (!success) {
    await setDefaultUserData(token);
  }
}

Future<void> loginApple(BuildContext context, String token) async {
  bool success = await loadMyUserData(token);
  if (!success) setDefaultUserData(token);
}

Future<void> setPlayerInGroup(
    String userID, String newGroupID, Player player) async {
  CollectionReference groupsRef =
      FirebaseFirestore.instance.collection('groups');

  await groupsRef.doc(newGroupID).collection('players').doc(userID).set({
    'name': player.name,
    'user_id': player.userID,
    'points': player.points,
    'state': player.state.index,
    'target': player.target,
    'eliminator': player.eliminator,
  });

}

Future<Player> getPlayerInGroup(Group group, String playerUID) async {
  CollectionReference groupsRef =
      FirebaseFirestore.instance.collection('groups');

  DocumentSnapshot playerDocument = await groupsRef
      .doc(group.groupName)
      .collection('players')
      .doc(playerUID)
      .get();

  if (playerDocument.exists) {
    int state = await playerDocument.get('state');
    PlayerState ps = PlayerState.alive;
    switch (state) {
      case 0:
        {
          ps = PlayerState.alive;
          break;
        }
      case 1:
        {
          ps = PlayerState.preparingToDie;
          break;
        }
      case 2:
        {
          ps = PlayerState.dead;
          break;
        }
    }

    UserData? playerUser = await getUserData(playerUID);

    String targetUID = await getTargetUID(group, playerUID);

    Player playerToReturn = Player(
      playerUser!.uid,
      playerDocument.get('points'),
      playerUser,
      target: targetUID,
      state: ps,
    );
    playerToReturn.name = playerUser.name;

    return playerToReturn;
  } else {
    throw Exception('Document does not exist (Inside getPlayerInGroup');
  }
}

StreamSubscription<DocumentSnapshot>? subscription;
StreamSubscription<QuerySnapshot>? playersSubscription;

void listenToGroupChanges(String groupID) {
  CollectionReference groupsRef =
      FirebaseFirestore.instance.collection('groups');

  DocumentReference groupDocRef = groupsRef.doc(groupID);

  // Listen to changes in the specified group document
  subscription = groupDocRef.snapshots().listen((event) async {
    await reloadSelectedGroup();
    triggerGroupUpdateEvent();
  });

  // Listen to changes in the "players" subcollection within the group document
  CollectionReference playersRef = groupDocRef.collection('players');
  playersSubscription = playersRef.snapshots().listen((snapshot) async {
    snapshot.docChanges.forEach((change) {
      if (change.type == DocumentChangeType.added) {
        // Handle added player document
        //print('Player added: ${change.doc.data()}');
      } else if (change.type == DocumentChangeType.modified) {
        // Handle modified player document
        //print('Player modified: ${change.doc.data()}');
      } else if (change.type == DocumentChangeType.removed) {
        // Handle removed player document
        //print('Player removed: ${change.doc.data()}');
      }
    });
    await reloadSelectedGroup();
    triggerGroupUpdateEvent();
  });

  // Listen to changes in any player document within the "players" subcollection
  playersRef.snapshots().listen((snapshot) async {
    snapshot.docChanges.forEach((change) {
      if (change.type == DocumentChangeType.modified) {
        // Handle modified player document
        //print('Any player modified: ${change.doc.data()}');
      }
    });

    await reloadSelectedGroup();
    triggerGroupUpdateEvent();
  });
}

void stopListeningToGroupChanges() {
  subscription?.cancel();
  subscription = null;
  playersSubscription?.cancel();
  playersSubscription = null;
}

Future<Group> createGroup(
    BuildContext context, String? userID, MatchOptions matchOptions) async {
  String newGroupID = getRandomString(5);

  CollectionReference groupsRef =
      FirebaseFirestore.instance.collection('groups');

  DocumentSnapshot gameSnapshot = await groupsRef.doc(newGroupID).get();
  if (gameSnapshot.exists) {
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
    'host': userID!,
    'state': GroupState.notStarted.index,
    'timeStarted': DateTime.utc(1989, 11, 9),
    'timeEnding': DateTime.utc(1989, 11, 9),
  });

  Player userPlayer = Player(userID, 0, null);
  userPlayer.name = globals.myUserData.name;
  await setPlayerInGroup(userID, newGroupID, userPlayer);

  Group newGroup = Group(
      newGroupID,
      {userID: Player(userID, 0, null)},
      matchOptions,
      userID,
      DateTime.utc(1989, 11, 9),
      DateTime.utc(1989, 11, 9));

  final snapshot = await FirebaseFirestore.instance
      .collection('group')
      .doc(newGroupID)
      .collection('players')
      .get();
  if (snapshot.size == 0) {
  } else {
    //print('there is a player collection');
  }

  globals.myGroups.add(newGroup);
  bool isNotInGroup = globals.myGroups.isEmpty;

  if (isNotInGroup) {
    globals.setSelectedGroup(newGroup);
  }
  await setUserData(userID, globals.myUserData, globals.myGroups);

  await loadPlayerNamesFromList(globals.selectedGroup.players.values.toList());

  return newGroup;
}

Future<JoinGameResults> joinGroup(
    BuildContext context, String gameCode, String? userID,
    {int points = 0}) async {
  DocumentReference gameRef =
      FirebaseFirestore.instance.collection('groups').doc(gameCode);

  try {
    DocumentSnapshot gameSnapshot =
        await gameRef.collection('players').doc(userID).get();
    if (gameSnapshot.exists) {
      return JoinGameResults(false, 'You are already a member of this game.');
    }
    try {
      var joinedGame = await loadGroup(gameCode);

      if (joinedGame.state != GroupState.notStarted) {
        return JoinGameResults(false,
            "This game is ongoing. Only games that have not been started may be joined.");
      }

      if (joinedGame.players.values.length ==
          joinedGame.matchOptions.maxPlayers) {
        return JoinGameResults(false, "Game is full.");
      }

      Player player = Player(userID!, points, null);
      player.name = globals.myUserData.name;
      await setPlayerInGroup(userID, gameCode, player);

      globals.myGroups.add(joinedGame);

      globals.setSelectedGroup(joinedGame);

      setUserData(userID, globals.myUserData, globals.myGroups);
      return JoinGameResults(true);
    } catch (e) {
      return JoinGameResults(false, "Game Not Found");
    }
  } catch (e) {
    print('Error adding user to game: $e');
    return JoinGameResults(false, "Unexpected Error");
  }
}

Future<void> updatePlayer(String playerID, String? name) async {
  var db = FirebaseFirestore.instance;
  final nameRef = db
      .collection("groups")
      .doc(globals.selectedGroup.groupName)
      .collection("players")
      .doc(playerID);
  nameRef.update({'name': name}).then(
      (value) => {},
      onError: (e) => print("Error updating document $e"));
}

void updateUserImage(String whatToChange, String changeTo) {
  var db = FirebaseFirestore.instance;
  final nameRef = db.collection("users").doc(globals.myUserData.uid);
  nameRef.update({whatToChange: changeTo}).then(
      (value) => {},
      onError: (e) => print("Error updating document $e"));
}

void updateUser(BuildContext context, String whatToChange, String changeTo) {
  var db = FirebaseFirestore.instance;
  final nameRef = db.collection("users").doc(globals.myUserData.uid);
  nameRef.update({whatToChange: changeTo}).then(
      (value) => {},
      onError: (e) => print("Error updating document $e"));
}

Future updateGroupState(Group selectedGroup) async {
  String groupID = selectedGroup.groupName;
  GroupState groupState = selectedGroup.state;
  await FirebaseFirestore.instance
      .collection('groups')
      .doc(groupID)
      .update({'state': groupState.index});
}

Future<String> getTargetUID(Group group, String playerUID) async {
  CollectionReference groupsRef =
      FirebaseFirestore.instance.collection('groups');

  DocumentSnapshot userDocument = await groupsRef
      .doc(group.groupName)
      .collection('players')
      .doc(playerUID)
      .get();

  String targetUID = await userDocument.get('target');

  return targetUID;
}

Future<void> startGameOrRespawn() async {
  /* things to note

    - game state is only initialized for player who created game
    - previous game information shows if you log out and log back in with another account that isn't in that previous game 
    - need to store target_uid for each player in groups on db (CHECK)
  */

  // reset all player states to zero
  await resetState(globals.selectedGroup);

  // reset all player points to zero
  await resetPoints(globals.selectedGroup);

  // reset all targets
  await resetTarget(globals.selectedGroup);

  //fetch the current group from the database and assign to globals.selectedGroup
  globals.selectedGroup = await loadGroup(globals.selectedGroup.groupName);

  List<Player> playerList = globals.selectedGroup.players.values.toList();
  playerList.shuffle();

  globals.selectedGroup.timeStarted = DateTime.now();
  globals.selectedGroup.timeEnding = DateTime.now().add(Duration(
      hours: globals.selectedGroup.matchOptions.totalGameTimeDuration));

  var groupSize = globals.selectedGroup.players.length;

  // assign targets to each player
  for (int i = 0; i < groupSize; i++) {
    Player player = playerList[i];
    player.target = playerList[(i + 1) % groupSize].userID;
    setPlayerInGroup(player.userID, globals.selectedGroup.groupName, player);

    if (player.userID == globals.myUserData.uid) {
      {
        await setCurrTarget(player.target);
      }
    }
  }
}

Future<void> resetPoints(Group group) async {
  CollectionReference playersRef = FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName)
      .collection('players');

  QuerySnapshot playerSnapshot = await playersRef.get();

  playerSnapshot.docs.forEach((playerDoc) {
    playersRef.doc(playerDoc.id).update({'points': 0});
  });
}

Future<void> resetState(Group group) async {
  CollectionReference playersRef = FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName)
      .collection('players');

  QuerySnapshot playerSnapshot = await playersRef.get();

  playerSnapshot.docs.forEach((playerDoc) {
    playersRef.doc(playerDoc.id).update({'state': 0});
  });
}

Future<void> resetTarget(Group group) async {
  CollectionReference playersRef = FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName)
      .collection('players');

  QuerySnapshot playerSnapshot = await playersRef.get();

  playerSnapshot.docs.forEach((playerDoc) {
    playersRef.doc(playerDoc.id).update({'target': ""});
  });
}

Future<void> setCurrTarget(String targetUID) async {
  globals.currentTarget = await getUserData(targetUID);
}

Future<void> loadCurrTarget({required String uid}) async {
  await setCurrTarget(globals.selectedGroup.players[uid]!.target);
}

Future<String> getCurrTargetUid(
    {required String playerUID, required String groupCode}) async {
  var db = FirebaseFirestore.instance;

  final docRef = db
      .collection("groups")
      .doc(groupCode)
      .collection("players")
      .doc(playerUID);

  try {
    var doc = await docRef.get();
    var data = doc.data() as Map<String, dynamic>;
    String targetUID = data['target'];
    return targetUID;
  } catch (e) {
    print("Error getting target: $e");
    return "default";
  }
}

Future<void> eliminatePlayer() async {
  
  CollectionReference groupsRef =
      FirebaseFirestore.instance.collection('groups');

  DocumentSnapshot userDocument = await groupsRef
      .doc(globals.selectedGroup.groupName)
      .collection('players')
      .doc(globals.myUserData.uid)
      .get();

  String eliminatorName = await userDocument.get('eliminator');
  String targetName = await userDocument.get('target');
  String myName = await userDocument.get('user_id');

  Player me = globals.selectedGroup.players[myName]!;
  me.state = PlayerState.dead;

  Player eliminator = globals.selectedGroup.players[eliminatorName]!;
  eliminator.points += 1;
  eliminator.target = targetName;

  setPlayerInGroup(myName, globals.selectedGroup.groupName, me);
  setPlayerInGroup(eliminatorName, globals.selectedGroup.groupName, eliminator);

  if(eliminator.target == eliminatorName) {
    globals.selectedGroup.state = GroupState.finished;
    await updateGroupState(globals.selectedGroup);
  }

}

Future logout(context) async {
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  await FirebaseAuth.instance.signOut().then((value) => Navigator.of(context)
      .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AuthPage()),
          (route) => false));
}
