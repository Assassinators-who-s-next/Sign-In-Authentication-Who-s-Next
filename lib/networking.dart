import 'package:basic_auth/pages/join_create_game_page.dart';
import 'package:basic_auth/player.dart';
import 'package:flutter/material.dart';
import 'pages/homepage.dart';

import 'game_group.dart';
import 'globals.dart' as globals;

// sends

void login_custom(BuildContext context, String userName, String password) {
  String my_name = "temp_user";
  List<player> players = [
    player("p_one", 1),
    player("p_two", 2),
    player("p_three", 3),
    player("p_four", 4)
  ];
  List<group> groups = [group("game_one", players)];
  List<group> empty_groups = [];

  load_responce(context, my_name, empty_groups);
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

  load_responce(context, my_name, groups);
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

  load_responce(context, my_name, groups);
}

// responces

// call this when the server responds with a list of groups
load_responce(BuildContext context, String my_name, List<group> groups) {
  if (groups.isEmpty) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JoinCreatePage()),
    );
  } else {
    globals.myName = my_name;
    globals.myGroups = groups;
    globals.selectedGroup = groups[0];

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }
}
