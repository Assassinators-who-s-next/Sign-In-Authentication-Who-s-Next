import 'package:basic_auth/models/user_data.dart';

class UserPreferences {
  static const String placeholderImagePath =
      "images/placeHolderProfileImage.jpg";
  static const user = UserData(
      imagePath: null,
      name: "Joe Smith",
      email: "joe@ucsc.edu",
      pronouns: "he\\him",
      description: "I love pizza and eliminating people!");
}
