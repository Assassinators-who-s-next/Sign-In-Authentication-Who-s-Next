// ignore_for_file: use_build_context_synchronously

import 'package:basic_auth/components/number_textfield.dart';
import '../globals.dart' as globals;
import 'package:basic_auth/utils/popup_modal.dart';
import 'package:flutter/material.dart';
import 'package:basic_auth/components/login_text_field.dart';
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

const List<String> typesOfElims = <String>[
  'Finger Guns',
  'Water Balloons',
  'Rubber Band Gun',
  'Pied to the Face'
];

enum RespawnType { weeks, days }

enum TotalTimeType { months, weeks, days }

const List<int> monthsList = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

const List<int> weeksList = <int>[1, 2, 3, 4];

const List<int> daysList = <int>[
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

List<int> receiveTotalTimeList(String totalTimeOption) {
  if (totalTimeOption == TotalTimeType.months.name) {
    return monthsList;
  } else if (totalTimeOption == TotalTimeType.weeks.name) {
    return weeksList;
  }

  return daysList;
}

List<int> receiveRespawnList(String respawnOption) {
  if (respawnOption == RespawnType.weeks.name) {
    return weeksList;
  }

  return daysList;
}

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({super.key});

  @override
  State<CreateGamePage> createState() => _CreateGamePage();
}

class _CreateGamePage extends State<CreateGamePage> {
  String? elimChoice = typesOfElims[0];
  RespawnType? respawnChoice;
  int? respawnDurationChoice;
  TotalTimeType? totalGameChoice;
  int? totalGameDurationChoice;

  List<int> selectedRespawnDurationList = <int>[];
  List<int> selectedTotalDurationList = <int>[];

  final offLimitController = TextEditingController();
  final staySafeController = TextEditingController();
  final maxPlayerController = TextEditingController();

  guidetoUserHome(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => (const HomePage())),
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
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
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

              eliminationType(),
              const Padding(
                padding: EdgeInsetsDirectional.only(bottom: 20),
              ),

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
                onPressed: () => onPressCreateGameButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onPressCreateGameButton(BuildContext context) async {
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
    if (maxPlayerController.text == '') {
      //popUp(context, 'Fill in the max number of players');
      showPopup(context,
          content: const Text('Fill in the max number of players'),
          bottomWidgets: [closeButton(context)]);
    } else if (int.parse(maxPlayerController.text) < 2 ||
        int.parse(maxPlayerController.text) > 100) {
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
          int.parse(maxPlayerController.text),
          elimChoice!,
          //respawn_choice!.name,
          "", //respawn_time_plural,
          0, //respawn_duration_choice!,
          //total_game_choice!.name,
          "", //tot_game_time_plural,
          0, //total_game_duration_choice,
          offLimitController.text,
          staySafeController.text);

      context.loaderOverlay.show();

      await createGroup(context, user?.uid, matchOptions)
          .then((value) => globals.setSelectedGroup(value));

      context.loaderOverlay.hide();
      guidetoUserHome(context);
    }
  }

  bool checkRespawnToTotalGameTime(String respawnChoice, int respawnDuration,
      String totalGameType, int totalGameTime) {

    if (respawnChoice == RespawnType.days.name) {
      if (totalGameType == TotalTimeType.days.name) {
        if (respawnDuration > totalGameTime) {
          return false;
        }
      } else if (totalGameType == TotalTimeType.weeks.name) {
        if (respawnDuration > totalGameTime * 7) {
          return false;
        }
      }
    }

    if (respawnChoice == RespawnType.weeks.name) {
      if (totalGameType == TotalTimeType.days.name) {
        if (respawnDuration * 7 > totalGameTime) {
          return false;
        }
      } else if (totalGameType == TotalTimeType.weeks.name) {
        if (respawnDuration > totalGameTime) {
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
          child: LoginTextField(
            controller: staySafeController,
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
          child: LoginTextField(
            controller: offLimitController,
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
            controller: maxPlayerController,
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
          value: elimChoice,
          onChanged: (String? value) {
            setState(() {
              elimChoice = value;
            });
          },
          items: typesOfElims.map<DropdownMenuItem<String>>((String value) {
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
              value: totalGameChoice,
              onChanged: (TotalTimeType? value) {
                setState(() {
                  totalGameChoice = value;
                  totalGameDurationChoice = null;
                  selectedTotalDurationList =
                      receiveTotalTimeList(totalGameChoice!.name);
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
              value: totalGameDurationChoice,
              onChanged: (int? newValue) {
                setState(() {
                  totalGameDurationChoice = newValue;
                });
              },
              items: selectedTotalDurationList
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value'),
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
              value: respawnChoice,
              onChanged: (RespawnType? value) {
                setState(() {
                  respawnChoice = value;
                  respawnDurationChoice = null;
                  selectedRespawnDurationList =
                      receiveRespawnList(respawnChoice!.name);
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
              value: respawnDurationChoice,
              onChanged: (int? value) {
                setState(() {
                  respawnDurationChoice = value;
                });
              },
              items: selectedRespawnDurationList
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}
