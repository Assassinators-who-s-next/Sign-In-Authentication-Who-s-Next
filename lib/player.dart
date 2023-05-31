import 'package:basic_auth/globals.dart';

import 'models/user_data.dart';

enum PlayerState { alive, preparingToDie, dead }

class Player {
  String? name;
  String userID;
  int points;
  UserData? userData;
  String target = "";
  String? eliminator;
  PlayerState state = PlayerState.alive;

  Player(this.userID, this.points, this.userData,
      {this.state = PlayerState.alive, target = "", eliminatedBy = null});

  String get_name() {
    if (name != null) return name!;

    if (userData != null) {
      return userData!.name;
    } else {
      return "";
    }
  }

  @override
  String toString() {
    return "Player:[ userID: " +
        userID +
        "\nname: " +
        (name ?? "null") +
        "\nPoints: " +
        "Points: " +
        points.toString() +
        "\n" +
        "State: " +
        state.toString() +
        "\n" +
        "Target: " +
        target +
        "]";
  }
}
