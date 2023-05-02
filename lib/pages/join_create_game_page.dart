import 'package:flutter/material.dart';
import '../networking.dart';
import 'home_page.dart';
import '../game_group.dart';
import '../player.dart';

class JoinCreatePage extends StatelessWidget {
  JoinCreatePage({super.key});
  final _formKey = GlobalKey<FormState>();
  TextEditingController gameCodeController = TextEditingController();

  void JoinGame(BuildContext context) {
    print("Join Game button pressed");

    join_game(context, gameCodeController.text);
  }

  void CreateGame(BuildContext context) {
    print("Create Game button pressed");

    create_game(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],

        // safe area ignores 'notch area' on different phone shapes
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter Game Code: (or create game)',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: gameCodeController,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: gameCodeController,
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: ElevatedButton(
                      //     child: Text("Submitß"),
                      //     onPressed: () {
                      //       //if (_formKey.currentState.validate()) {
                      //       //  _formKey.currentState.save();
                      //       //}
                      //     },
                      //   ),
                      // )
                    ],
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () => JoinGame(context),
                  child: Text('Join Game'),
                ),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () => CreateGame(context),
                  child: Text('Create Game'),
                ),
              ],
            ),
          ),
        ));
  }
}
