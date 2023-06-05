import 'package:basic_auth/components/number_textfield.dart';
import 'package:basic_auth/globals.dart';
import 'package:basic_auth/pages/user_home.dart';
import 'package:basic_auth/utils/popup_modal.dart';
import 'package:flutter/material.dart';
import 'package:basic_auth/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../models/match_options.dart';
import 'package:basic_auth/networking.dart';

import 'home_page.dart';

/**
 * Sources:
 * Dynamic DropDownItems based on previous DropDownItems selection:
 *    https://stackoverflow.com/questions/70140798/dynamic-drop-down-field-based-on-selection
 * DropdownButton with enums:
 *    https://stackoverflow.com/questions/54378290/dropdownbutton-with-int-items-not-working-it-does-not-select-new-value
 */

const List<String> types_of_elims = <String>[
  'Finger Guns',
  'Water Balloons',
  'Rubber Band Gun',
  'Pied to the Face'
];

enum RespawnType { Weeks, Days }

enum TotalTimeType { Months, Weeks, Days }

const List<int> months_list = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

const List<int> weeks_list = <int>[1, 2, 3, 4];

const List<int> days_list = <int>[
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18,
  19,
  20,
  21,
  22,
  23,
  24,
  25,
  26,
  27,
  28
];

List<int> receiveTotalTimeList(String total_time_option) {
  // return months list if respawn choice is 'Months'
  if (total_time_option == TotalTimeType.Months.name) {
    return months_list;
    // return weeks list if respawn choice is 'Weeks'
  } else if (total_time_option == TotalTimeType.Weeks.name) {
    return weeks_list;
  }

  // otherwise return days list if respawn choice is 'Days'
  return days_list;
}

List<int> receiveRespawnList(String respawn_option) {
  // return weeks list if respawn choice is 'Weeks'
  if (respawn_option == RespawnType.Weeks.name) {
    return weeks_list;
  }

  // otherwise return days list if respawn choice is 'Days'
  return days_list;
}

class CreateGamePage extends StatefulWidget {
  @override
  State<CreateGamePage> createState() => _CreateGamePage();
}

class _CreateGamePage extends State<CreateGamePage> {
  String? elim_choice = types_of_elims[0];
  RespawnType? respawn_choice;
  int? respawn_duration_choice;
  TotalTimeType? total_game_choice;
  int? total_game_duration_choice;

  List<int> selected_respawn_duration_list = <int>[];
  List<int> selected_total_duration_list = <int>[];

  final off_limit_controller = TextEditingController();
  final stay_safe_controller = TextEditingController();
  final max_player_controller = TextEditingController();

  guidetoUserHome(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => (HomePage())),
    );
  }

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    var screenWidth = queryData.size.width;

    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Create Game'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.only(left: 20, top: 20, right: 20),
            children: [
              /*
              const Text(
                'Game Time',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsetsDirectional.only(bottom: 20),
              ),

              // respawn info
              respawnType(),
              const Padding(padding: EdgeInsetsDirectional.only(bottom: 20)),

              // total game info
              totalGameType(),
              const Padding(padding: EdgeInsetsDirectional.only(bottom: 20)),
              */

              const Text(
                'Rules',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsetsDirectional.only(bottom: 20),
              ),

              maxPlayers(screenWidth: screenWidth),
              const Padding(
                padding: EdgeInsetsDirectional.only(bottom: 20),
              ),

              // elimination type
              eliminationType(),
              const Padding(
                padding: EdgeInsetsDirectional.only(bottom: 20),
              ),

              // off limit info
              offLimitInfo(screenWidth),
              const Padding(
                padding: EdgeInsetsDirectional.only(bottom: 20),
              ),

              staySafeInfo(screenWidth),
              const Padding(
                padding: EdgeInsetsDirectional.only(bottom: 20),
              ),

              TextButton(
                child: const Text(
                  'Create',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => OnPressCreateGameButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void OnPressCreateGameButton(BuildContext context) async {
    // test if fields were inputted correctly
    /*
    if (respawn_choice == null || respawn_duration_choice == null) {
      //popUp(context, 'Fill out Respawn Information');
      showPopup(context,
          content: const Text('Fill out Respawn Information'),
          bottomWidgets: [closeButton(context)]);
    } else if (total_game_choice == null ||
        total_game_duration_choice == null) {
      //popUp(context, 'Fill out Game Duration Information');
      showPopup(context,
          content: const Text('Fill out Game Duration Information'),
          bottomWidgets: [closeButton(context)]);
    } else if (checkRespawnToTotalGameTime(
            respawn_choice!.name,
            respawn_duration_choice!,
            total_game_choice!.name,
            total_game_duration_choice!) ==
        false) {
      //popUp(context,
      //    'Total game time must be greater or equal to the respawn time');
      showPopup(context,
          content: const Text(
              'Total game time must be greater or equal to the respawn time'),
          bottomWidgets: [closeButton(context)]);
      // otherwise go to home page
    } else */
    if (max_player_controller.text == '') {
      //popUp(context, 'Fill in the max number of players');
      showPopup(context,
          content: const Text('Fill in the max number of players'),
          bottomWidgets: [closeButton(context)]);
    } else if (int.parse(max_player_controller.text) < 2 ||
        int.parse(max_player_controller.text) > 100) {
      //popUp(context, 'Number of players must be 2 - 100 players');
      showPopup(context,
          content: const Text('Number of players must be 2 - 100 players'),
          bottomWidgets: [closeButton(context)]);
    } else {
      /*
      // save plural or singular form depending on length of game time
      var tot_game_time_plural;
      if (total_game_duration_choice! == 1) {
        tot_game_time_plural = total_game_choice!.name
            .substring(0, total_game_choice!.name.length - 1);
      } else {
        tot_game_time_plural = total_game_choice!.name;
      }

      // save plural or singular form depending on length of respawn time
      var respawn_time_plural;
      if (respawn_duration_choice! == 1) {
        respawn_time_plural =
            respawn_choice!.name.substring(0, respawn_choice!.name.length - 1);
      } else {
        respawn_time_plural = respawn_choice!.name;
      }
      */

      User? user = FirebaseAuth.instance.currentUser;
      MatchOptions matchOptions = MatchOptions(
          int.parse(max_player_controller.text),
          elim_choice!,
          //respawn_choice!.name,
          "", //respawn_time_plural,
          0, //respawn_duration_choice!,
          //total_game_choice!.name,
          "", //tot_game_time_plural,
          0, //total_game_duration_choice,
          off_limit_controller.text,
          stay_safe_controller.text);

      context.loaderOverlay.show();
      // creates game with game info and creates game code
      await createGroup(context, user?.uid, matchOptions)
          .then((value) => setSelectedGroup(value));

      context.loaderOverlay.hide();
      guidetoUserHome(context);
    }
  }

  bool checkRespawnToTotalGameTime(String respawn_choice, int respawn_duration,
      String total_game_type, int total_game_time) {
    // check day
    if (respawn_choice == RespawnType.Days.name) {
      // respawn day vs total game time day
      if (total_game_type == TotalTimeType.Days.name) {
        if (respawn_duration > total_game_time) {
          return false;
        }
        // respawn day vs total game time week
      } else if (total_game_type == TotalTimeType.Weeks.name) {
        if (respawn_duration > total_game_time * 7) {
          return false;
        }
      }
    }

    // check week
    if (respawn_choice == RespawnType.Weeks.name) {
      // respawn week vs total game time day
      if (total_game_type == TotalTimeType.Days.name) {
        if (respawn_duration * 7 > total_game_time) {
          return false;
        }
        // respawn week vs total game time week
      } else if (total_game_type == TotalTimeType.Weeks.name) {
        if (respawn_duration > total_game_time) {
          return false;
        }
      }
    }

    return true;
  }

  Row staySafeInfo(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('How to stay safe:'),
        SizedBox(
          width: screenWidth / 2,
          child: MyTextField(
            controller: stay_safe_controller,
            hintText: 'eg. floaties...',
            obscureText: false,
          ),
        ),
      ],
    );
  }

  Row offLimitInfo(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Off Limit Areas:'),
        SizedBox(
          width: screenWidth / 2,
          child: MyTextField(
            controller: off_limit_controller,
            hintText: 'eg. school, mall...',
            obscureText: false,
          ),
        ),
      ],
    );
  }

  Row maxPlayers({required double screenWidth}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Max Players:'),
        SizedBox(
          width: screenWidth / 2,
          child: NumberTextField(
            controller: max_player_controller,
            hintText: '2 - 100 players',
            obscureText: false,
          ),
        ),
      ],
    );
  }

  Row eliminationType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Elimination Type:'),
        DropdownButton(
          hint: const Text('Elimination Type'),
          value: elim_choice,
          onChanged: (String? value) {
            setState(() {
              elim_choice = value;
            });
          },
          items: types_of_elims.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Row totalGameType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Total Game Time:'),
        Column(
          children: [
            DropdownButton<TotalTimeType>(
              hint: const Text('Duration Type'),
              value: total_game_choice,
              onChanged: (TotalTimeType? value) {
                setState(() {
                  total_game_choice = value;
                  total_game_duration_choice = null;
                  selected_total_duration_list =
                      receiveTotalTimeList(total_game_choice!.name);
                });
              },
              items: TotalTimeType.values.map((TotalTimeType value) {
                return DropdownMenuItem<TotalTimeType>(
                  value: value,
                  child: Text(value.name),
                );
              }).toList(),
            ),
            DropdownButton<int>(
              hint: const Text('Duration Time:'),
              value: total_game_duration_choice,
              onChanged: (int? new_value) {
                setState(() {
                  total_game_duration_choice = new_value;
                });
              },
              items: selected_total_duration_list
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('${value}'),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Row respawnType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Respawn\nTimer:',
          textDirection: TextDirection.ltr,
        ),
        Column(
          children: [
            DropdownButton<RespawnType>(
              hint: const Text('Select Respawn Type:'),
              value: respawn_choice,
              onChanged: (RespawnType? value) {
                setState(() {
                  respawn_choice = value;
                  // reset second dropdown if changed respawn choice
                  respawn_duration_choice = null;
                  // change duration list based on respawn choice
                  selected_respawn_duration_list =
                      receiveRespawnList(respawn_choice!.name);
                });
              },
              items: RespawnType.values.map((RespawnType value) {
                return DropdownMenuItem<RespawnType>(
                  value: value,
                  child: Text(value.name),
                );
              }).toList(),
            ),
            DropdownButton<int>(
              hint: const Text('Select Respawn Time:'),
              value: respawn_duration_choice,
              onChanged: (int? value) {
                setState(() {
                  respawn_duration_choice = value;
                });
              },
              items: selected_respawn_duration_list
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('${value}'),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}
