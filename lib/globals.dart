library whos_next.globals;

import 'package:firebase_auth/firebase_auth.dart';

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
group selectedGroup = group(
    "no",
    [],
    MatchOptions(
      'Single',
      'Fixed',
      5,
      'Limited',
      60,
      'Area A',
      'Helmet',
    ));
List<group> myGroups = [];
User? fireBaseUser;
