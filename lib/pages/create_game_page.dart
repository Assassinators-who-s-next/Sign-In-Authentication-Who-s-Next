import 'package:basic_auth/pages/user_home.dart';
import 'package:flutter/material.dart';
import 'package:basic_auth/components/my_textfield.dart';
import 'homepage.dart';

/**
 * Sources:
 * Dynamic DropDownItems based on previous DropDownItems selection:
 *    https://stackoverflow.com/questions/70140798/dynamic-drop-down-field-based-on-selection
 */

const List<String> types_of_elims = <String>[
  'Finger Guns',
  'Water Balloons',
  'Camera Snipe',
  'Pied to the Face',
];

const List<String> respawn_type = <String>[
  'Days',
  'Weeks',
];

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
  '28',
  '29',
  '30'
];

const List<String> weeks_list = <String>['1', '2', '3', '4'];

List<String> receiveList(String respawn_option) {
  // return days list if respawn choice is 'Days'
  if (respawn_option == respawn_type[0]) {
    return days_list;
  }

  // otherwise return weeks list if respawn choice is 'Weeks'
  return weeks_list;
}

class CreateGamePage extends StatefulWidget {
  @override
  State<CreateGamePage> createState() => _CreateGamePage();
}

class _CreateGamePage extends State<CreateGamePage> {
  String? elim_choice;
  String? respawn_choice;
  String? duration_choice;

  List<String> selected_duration_list = <String>[];

  final off_limit_controller = TextEditingController();
  final stay_safe_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    var screenHeight = queryData.size.height;
    var screenWidth = queryData.size.width;

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Create Game'),
          backgroundColor: Colors.orange),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(left: 20, top: 30, right: 20),
          children: [
            const Text(
              'Game Time',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsetsDirectional.only(bottom: 30),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Respawn Timer'),
                DropdownButton(
                  hint: Text('Select Respawn Time:'),
                  value: respawn_choice,
                  onChanged: (String? value) {
                    setState(() {
                      respawn_choice = value;
                      // reset second dropdown if changed respawn choice
                      duration_choice = null;
                      // change duration list based on respawn choice
                      selected_duration_list =
                          receiveList(respawn_choice.toString());
                    });
                  },
                  items: respawn_type
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const Padding(padding: EdgeInsetsDirectional.only(bottom: 30)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Duration'),
                DropdownButton(
                  hint: Text('Select Duration Time:'),
                  value: duration_choice,
                  onChanged: (String? value) {
                    //if (mounted) {
                    setState(() {
                      duration_choice = value;
                    });
                  },
                  items: selected_duration_list
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const Padding(padding: EdgeInsetsDirectional.only(bottom: 30)),

            const Text(
              'Rules',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsetsDirectional.only(bottom: 30),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Elimination Type:'),
                DropdownButton(
                  hint: Text('Select Elimination'),
                  value: elim_choice,
                  onChanged: (String? value) {
                    setState(() {
                      elim_choice = value;
                    });
                  },
                  items: types_of_elims
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsetsDirectional.only(bottom: 30),
            ),

            Row(
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
            ),
            const Padding(
              padding: EdgeInsetsDirectional.only(bottom: 30),
            ),

            Row(
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
            ),
            const Padding(
              padding: EdgeInsetsDirectional.only(bottom: 30),
            ),

            // TODO: change look of button
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              },
              child: Text(
                'Create',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
