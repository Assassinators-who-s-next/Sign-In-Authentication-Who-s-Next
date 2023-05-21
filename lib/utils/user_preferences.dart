import 'package:basic_auth/models/user_data.dart';

class UserPreferences {
  static String placeholderImagePath = "lib/images/placeHolderProfileImage.jpg";
  var user = UserData(
      uid: "default user id",
      imagePath: null,
      name: "Joe Smith",
      email: "joe@ucsc.edu",
      pronouns: "he\\him",
      description: "I love pizza and eliminating people!",
      frequentedLocations: "BSOE Library, Crown/Merrill Dining Hall");
}
