import 'package:basic_auth/pages/join_create_game_page.dart';
import 'package:basic_auth/player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';

import 'game_group.dart';

// sends

Widget login_custom(BuildContext context, String? email) {
  String my_name = "temp_user";
  List<player> players = [
    player("p_one", 1),
    player("p_two", 2),
    player("p_three", 3),
    player("p_four", 4)
  ];
  List<group> groups = [group("game_one", players)];
  List<group> empty_groups = [];

  return load_response(context, my_name, empty_groups);
}

void signUserIn(BuildContext context, String email, String password) async {
  // loading circle thingy
  showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      });

  // try to sign user in
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // pop off loading circle
    Navigator.pop(context);
  } on FirebaseAuthException catch (e) {
    // pop off loading circle
    Navigator.pop(context);

    // incorrect user name
    showErrorMessage(context, e.code);
  }
}

// error message for log in
void showErrorMessage(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return Center(
        child: AlertDialog(
            title: Text(
          message,
          style: TextStyle(color: Colors.black),
        )),
      );
    },
  );
}

void login_google(BuildContext context, String token) {}

void login_apple(BuildContext context, String token) {}

void create_game(BuildContext context) {
  String my_name = "temp_user2";
  List<player> players = [
    player("p_one", 1),
    player("p_two", 2),
    player("p_three", 3),
    player("p_four", 4)
  ];
  List<group> groups = [group("game_two", players)];

  load_response(context, my_name, groups);
}

void join_game(BuildContext context, String game_code) {
  String my_name = "temp_user3";
  List<player> players = [
    player("p_one", 1),
    player("p_two", 2),
    player("p_three", 3),
    player("p_four", 4)
  ];
  List<group> groups = [group("game_three", players)];

  load_response(context, my_name, groups);
}

// responces

// call this when the server responds with a list of groups
load_response(BuildContext context, String my_name, List<group> groups) {

  if (groups.isEmpty) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JoinCreatePage()),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HomePage(name: my_name, groups: groups)),
    );
  }
}
