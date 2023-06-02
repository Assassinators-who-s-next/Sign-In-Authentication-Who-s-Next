import 'package:basic_auth/globals.dart';

import 'models/user_data.dart';

enum PlayerState { alive, preparingToDie, dead }

class Player {
  String? name;
  String userID; // exist on the database
  int points; // exist on the database
  UserData? userData;

  String target = ""; // exist on the database
  String? eliminator; // exist on the database
  PlayerState state = PlayerState.alive; // exist on the database
  Player(this.userID, this.points, this.userData, {this.state = PlayerState.alive, this.target = "", this.eliminator});

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
