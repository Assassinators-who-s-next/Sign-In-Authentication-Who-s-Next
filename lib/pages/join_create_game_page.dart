// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:basic_auth/pages/create_game_page.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../models/join_game_results.dart';
import '../networking.dart';
import '../utils/popup_modal.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinCreatePage extends StatelessWidget {
  final Color createButtonColor = const Color.fromARGB(255, 233, 58, 45);
  final Color joinButtonColor = Colors.blue;

  final formKey = GlobalKey<FormState>();
  final TextEditingController gameCodeController = TextEditingController();
  
  JoinCreatePage({super.key});

  void joinGame(BuildContext context) async {
    String gameCode = gameCodeController.text.trim();
    if (gameCode == "") {
      showSimplePopupWithCancel(context,
          contentText: "Must supply game code in order to join match.");
      return;
    }

    context.loaderOverlay.show();

    User? user = FirebaseAuth.instance.currentUser;
    JoinGameResults results = JoinGameResults(false, "Join failure.");
    await joinGroup(context, gameCode, user?.uid)
        .then((value) => {results = value});

    context.loaderOverlay.hide();

    if (!results.success) {
      showSimplePopupWithCancel(context, contentText: results.errorMessage);
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => (const HomePage())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
          backgroundColor: Colors.grey[300],
          appBar: AppBar(
            title: const Text('Enter the game'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => (const HomePage())),
                );
              },
            ),
          ),

          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: gameCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Join Code',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 130,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: joinButtonColor, // background color
                            onPrimary: Colors.white, // foreground color
                            shadowColor: joinButtonColor, // elevation color
                            elevation: 5, // elevation of button
                          ),
                          onPressed: () => joinGame(context),
                          child: const Text('Join Game',
                              style: (TextStyle(fontSize: 17.0))),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Row(children: [
                        Expanded(
                          child: Container(
                              margin: const EdgeInsets.only(
                                  left: 30.0, right: 20.0),
                              child: const Divider(
                                color: Colors.black,
                                height: 36,
                              )),
                        ),
                        const Text("OR"),
                        Expanded(
                          child:  Container(
                              margin: const EdgeInsets.only(
                                  left: 20.0, right: 30.0),
                              child: const Divider(
                                color: Colors.black,
                                height: 36,
                              )),
                        ),
                      ]),
                      const SizedBox(height: 20.0),

                      SizedBox(
                        width: 170.0,
                        height: 70.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: createButtonColor, // background color
                              onPrimary: Colors.white, // foreground color
                              shadowColor: createButtonColor, // elevation color
                              elevation: 5, // elevation of button
                              shape: const StadiumBorder()),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CreateGamePage()),
                            );
                          },
                          child: const Text('Create Game',
                              style: TextStyle(fontSize: 18.0)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
