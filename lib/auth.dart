import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:basic_auth/game_group.dart';
import 'package:basic_auth/networking.dart';
import 'package:basic_auth/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/create_game_page.dart';



class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // user logged in
              String? email = FirebaseAuth.instance.currentUser?.email;

              //login_custom(context, "whatever", "password");


              return CreateGamePage();
              // user not logged in
            }else{
              return LoginPage();
            }
          }),
    );
  }
}
