import 'models/user_data.dart';

enum PlayerState { alive, preparingToDie, dead }

class Player {
  String? name;
  String userID;
  int points;
  UserData? userData;
  String? target_uid;
  PlayerState state = PlayerState.alive;
  Player(this.userID, this.points, this.userData, {this.target_uid, this.state = PlayerState.alive});

  String get_name() {
    if (userData != null) {
      return userData!.name;
    } else {
      return userID ?? "Unknown";
    }
  }
}
