import 'package:basic_auth/pages/user_home.dart';
import 'package:flutter/material.dart';
import 'package:basic_auth/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../networking.dart';

// import 'homepage.dart';
import 'home_page.dart';

/**
 * Sources:
 * Dynamic DropDownItems based on previous DropDownItems selection:
 *    https://stackoverflow.com/questions/70140798/dynamic-drop-down-field-based-on-selection
 */

const List<String> types_of_elims = <String>[
  'Finger Guns',
  'Water Balloons',
  'Camera Snipe',
  'Pied to the Face'
];

const List<String> respawn_type = <String>['Weeks', 'Days'];

const List<String> total_time_type = <String>['Months', 'Weeks', 'Days'];

const List<String> months_list = <String>[
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10',
  '11',
  '12'
];

const List<String> weeks_list = <String>['1', '2', '3', '4'];

const List<String> days_list = <String>[
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10',
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20',
  '21',
  '22',
  '23',
  '24',
  '25',
  '26',
  '27',
  '28'
];

List<String> receiveTotalTimeList(String total_time_option) {
  // return months list if respawn choice is 'Months'
  if (total_time_option == total_time_type[0]) {
    return months_list;
    // return weeks list if respawn choice is 'Weeks'
  } else if (total_time_option == total_time_type[1]) {
    return weeks_list;
  }

  // otherwise return days list if respawn choice is 'Days'
  return days_list;
}

List<String> receiveRespawnList(String respawn_option) {
  // return weeks list if respawn choice is 'Weeks'
  if (respawn_option == respawn_type[0]) {
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
  String? elim_choice;
  String? respawn_choice;
  String? respawn_duration_choice;
  String? total_game_choice;
  String? total_game_duration_choice;

  List<String> selected_respawn_duration_list = <String>[];
  List<String> selected_total_duration_list = <String>[];

  final off_limit_controller = TextEditingController();
  final stay_safe_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    var screenWidth = queryData.size.width;

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Create Game'),
          backgroundColor: Colors.orange),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(left: 20, top: 20, right: 20),
          children: [
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

            const Text(
              'Rules',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

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
              onPressed: () {
                User? user = FirebaseAuth.instance.currentUser;
                createGame(context, user?.uid);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => (HomePage())),
                );
                //print('go to join/create page');
                // check  all options have been filled
                if (respawn_choice == null ||
                    respawn_duration_choice == null ||
                    total_game_choice == null ||
                    total_game_duration_choice == null ||
                    elim_choice == null ||
                    off_limit_controller.text == '' ||
                    stay_safe_controller.text == '') {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          title: Text('Fill out all fields',
                              textAlign: TextAlign.center),
                        );
                      });
                  // check durations of respawn and total game time
                } else if (checkRespawnToTotalGameTime(
                        respawn_choice.toString(),
                        int.parse(respawn_duration_choice.toString()),
                        total_game_choice.toString(),
                        int.parse(total_game_duration_choice.toString())) ==
                    false) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          title: Text(
                              'Total game time must be greater or equal to the respawn time',
                              textAlign: TextAlign.center),
                        );
                      });
                  // otherwise go to home page
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => (HomePage())),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  bool checkRespawnToTotalGameTime(String respawn_choice, int respawn_duration,
      String total_game_type, int total_game_time) {
    // check day
    if (respawn_choice == respawn_type[1]) {
      // respawn day vs total game time day
      if (total_game_type == total_time_type[2]) {
        if (respawn_duration > total_game_time) {
          return false;
        }
        // respawn day vs total game time week
      } else if (total_game_type == total_time_type[1]) {
        if (respawn_duration > total_game_time * 7) {
          return false;
        }
      }
    }

    // check week
    if (respawn_choice == respawn_type[0]) {
      // respawn week vs total game time day
      if (total_game_type == total_time_type[2]) {
        if (respawn_duration * 7 > total_game_time) {
          return false;
        }
        // respawn week vs total game time week
      } else if (total_game_type == total_time_type[1]) {
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
        const Text('Off Limit Areas: '),
        SizedBox(
          width: screenWidth / 2,
          child: MyTextField(
            controller: off_limit_controller,
            hintText: 'eg. School, Mall...',
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
          hint: const Text('Select Elimination'),
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
            DropdownButton(
              hint: Text('Select Time Type'),
              value: total_game_choice,
              onChanged: (String? value) {
                setState(() {
                  total_game_choice = value;
                  total_game_duration_choice = null;
                  selected_total_duration_list =
                      receiveTotalTimeList(total_game_choice.toString());
                });
              },
              items:
                  total_time_type.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton(
              hint: Text('Select Total Time:'),
              value: total_game_duration_choice,
              onChanged: (String? value) {
                setState(() {
                  total_game_duration_choice = value;
                });
              },
              items: selected_total_duration_list
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
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
            DropdownButton(
              hint: Text('Select Respawn Type:'),
              value: respawn_choice,
              onChanged: (String? value) {
                setState(() {
                  respawn_choice = value;
                  // reset second dropdown if changed respawn choice
                  respawn_duration_choice = null;
                  // change duration list based on respawn choice
                  selected_respawn_duration_list =
                      receiveRespawnList(respawn_choice.toString());
                });
              },
              items: respawn_type.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton(
              hint: Text('Select Respawn Time:'),
              value: respawn_duration_choice,
              onChanged: (String? value) {
                setState(() {
                  respawn_duration_choice = value;
                });
              },
              items: selected_respawn_duration_list
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}
