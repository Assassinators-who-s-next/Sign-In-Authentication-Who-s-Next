import 'models/user_data.dart';

class player {
  String? name;
  String userID;
  int points;
  UserData? userData;
  player(this.userID, this.points, this.userData);

  String get_name() {
    if (userData != null) {
      return userData!.name;
    } else {
      return userID;
    }
  }
}
