import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:basic_auth/game_group.dart';
import 'package:basic_auth/networking.dart';
import 'package:basic_auth/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'globals.dart';
import 'pages/home_page.dart';
import 'pages/create_game_page.dart';
import 'pages/join_create_game_page.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  bool finishedLoading = false;
  bool loadingUser = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // user logged in
              String? email = FirebaseAuth.instance.currentUser?.email;
              String? uid = FirebaseAuth.instance.currentUser?.uid;

              //login_custom(context, "whatever", "password");
              if (!loadingUser) Login(context, email, uid);

              return HomePage();
              // user not logged in
            } else {
              return LoginPage();
            }
          }),
    );
  }

  void Login(BuildContext context, String? email, String? uid) async {
    loadingUser = true;
    SetFinishedLoadingState(false);
    await login_google(context, email!, uid!);

    try {
      if (hasSelectedGroup && selectedGroup.state == GroupState.running)
        currentTarget = await get_user_data(await get_curr_target_uid(playerUID: uid, groupCode: selectedGroup.group_name));
    } catch (E) {
      print("ERROR!!!!: ${E}");
    }

    SetFinishedLoadingState(true);
    loadingUser = false;
  }
}
