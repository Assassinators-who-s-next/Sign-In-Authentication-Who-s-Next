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
      {this.state = PlayerState.alive, this.target = "", this.eliminator});

  String getName() {
    if (name != null) return name!;

    if (userData != null) {
      return userData!.name;
    } else {
      return "";
    }
  }

  @override
  String toString() {
    return "Player:[ userID: $userID\nname: ${name ?? "null"}\nPoints: Points: $points\nState: $state\nTarget: $target]";
  }
}
