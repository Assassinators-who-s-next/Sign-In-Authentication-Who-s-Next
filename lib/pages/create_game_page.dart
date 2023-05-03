import 'package:basic_auth/pages/user_home.dart';
import 'package:flutter/material.dart';
import 'package:basic_auth/components/my_textfield.dart';

import 'homepage.dart';

const List<String> types_of_elims = <String>[
  'Finger Guns',
  'Water Balloons',
  'Camera Snipe',
  'Pied to the Face',
];

class CreateGamePage extends StatefulWidget {
  @override
  State<CreateGamePage> createState() => _CreateGamePage();
}

class _CreateGamePage extends State<CreateGamePage> {
  String elim_choice = types_of_elims.first;

  final off_limit_controller = TextEditingController();
  final stay_safe_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    var screenHeight = queryData.size.height;
    var screenWidth = queryData.size.width;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Create Game'), backgroundColor: Colors.orange),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(left: 20, top: 30, right: 20),
          children: [
            // TODO: menu scroller to choose days or week
            Text(
              'Respawn Timer: days/weeks',
              style: TextStyle(fontSize: 20),
            ),
            const Padding(padding: EdgeInsetsDirectional.only(bottom: 30)),

            const Text(
              'Duration: days/weeks/months/year(max)',
              style: TextStyle(fontSize: 20),
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
                  value: elim_choice,
                  onChanged: (String? value) {
                    setState(() {
                      elim_choice = value!;
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
                    hintText: 'eg. School, Mall',
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
                    hintText: 'eg. floaties, ',
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
                //print('go to join/create page');
              },
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
