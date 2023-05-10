// import 'package:basic_auth/pages/create_game_page.dart';
// import 'package:flutter/material.dart';
// import '../networking.dart';
// import 'home_page.dart';
// import '../game_group.dart';
// import '../player.dart';

// class JoinCreatePage extends StatelessWidget {
//   JoinCreatePage({super.key});
//   final _formKey = GlobalKey<FormState>();
//   TextEditingController gameCodeController = TextEditingController();

//   void JoinGame(BuildContext context) {
//     print("Join Game button pressed");

//     join_game(context, gameCodeController.text);
//   }

//   void CreateGame(BuildContext context) {
//     print("Create Game button pressed");

//     create_game(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.grey[300],

//         // safe area ignores 'notch area' on different phone shapes
//         body: SafeArea(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Enter Game Code: (or create game)',
//                   textAlign: TextAlign.center,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: TextFormField(
//                           controller: gameCodeController,
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: TextFormField(
//                           controller: gameCodeController,
//                         ),
//                       ),
//                       // Padding(
//                       //   padding: const EdgeInsets.all(8.0),
//                       //   child: ElevatedButton(
//                       //     child: Text("Submitß"),
//                       //     onPressed: () {
//                       //       //if (_formKey.currentState.validate()) {
//                       //       //  _formKey.currentState.save();
//                       //       //}
//                       //     },
//                       //   ),
//                       // )
//                     ],
//                   ),
//                 ),
//                 TextButton(
//                   style: ButtonStyle(
//                     foregroundColor:
//                         MaterialStateProperty.all<Color>(Colors.blue),
//                   ),
//                   onPressed: () => JoinGame(context),
//                   child: Text('Join Game'),
//                 ),
//                 TextButton(
//                   style: ButtonStyle(
//                     foregroundColor:
//                         MaterialStateProperty.all<Color>(Colors.blue),
//                   ),
//                   onPressed: () => {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => CreateGamePage()),
//                     ),
//                   },
//                   //onPressed: () => CreateGame(context),
//                   child: Text('Create Game'),
//                 ),
//               ],
//             ),
//           ),
//         ));
//   }
// }

import 'package:basic_auth/pages/create_game_page.dart';
// import 'create_game_page.dart';
import 'package:flutter/material.dart';
import '../networking.dart';
import 'home_page.dart';
import '../game_group.dart';
import '../player.dart';

import 'package:firebase_auth/firebase_auth.dart';

class JoinCreatePage extends StatelessWidget {
  var createButtonColor = Color.fromARGB(255, 233, 58, 45);

  JoinCreatePage({super.key});
  final _formKey = GlobalKey<FormState>();
  TextEditingController gameCodeController = TextEditingController();

  void JoinGame(BuildContext context) async {
    print("Join Game button pressed");
    User? user = FirebaseAuth.instance.currentUser;
    join_game(context, gameCodeController.text, user?.uid);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => (HomePage())),
    );

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => HomePage()),
    // );
  }

  void CreateGame(BuildContext context) async {
    print("Create Game button pressed");
    User? user = FirebaseAuth.instance.currentUser;
    createGame(context, user?.uid);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => (CreateGamePage())),
    );

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => CreateGamePage()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Text('Enter the game'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {},
          ),
        ),

        // safe area ignores 'notch area' on different phone shapes
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: gameCodeController,
                    decoration: InputDecoration(
                      labelText: 'Join Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //This is Join Game Button
                    SizedBox(
                      width: 130,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => JoinGame(context),
                        child: Text('Join Game',
                            style: (TextStyle(fontSize: 17.0))),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Row(children: [
                      Expanded(
                        child: new Container(
                            margin:
                                const EdgeInsets.only(left: 30.0, right: 20.0),
                            child: Divider(
                              color: Colors.black,
                              height: 36,
                            )),
                      ),
                      Text("OR"),
                      Expanded(
                        child: new Container(
                            margin:
                                const EdgeInsets.only(left: 20.0, right: 30.0),
                            child: Divider(
                              color: Colors.black,
                              height: 36,
                            )),
                      ),
                    ]),
                    SizedBox(height: 20.0),
                    // This is Create Game Button
                    SizedBox(
                      width: 170.0,
                      height: 70.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: createButtonColor, // background color
                            onPrimary: Colors.white, // foreground color
                            shadowColor: createButtonColor, // elevation color
                            elevation: 5, // elevation of button
                            shape: StadiumBorder()),
                        onPressed: () => CreateGame(context),
                        child: Text('Create Game',
                            style: TextStyle(fontSize: 18.0)),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
