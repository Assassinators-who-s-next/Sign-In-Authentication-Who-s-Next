import 'package:basic_auth/networking.dart';
import 'package:basic_auth/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'globals.dart';
import 'pages/home_page.dart';

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
              String? email = FirebaseAuth.instance.currentUser?.email;
              String? uid = FirebaseAuth.instance.currentUser?.uid;

              if (!loadingUser) login(context, email, uid);

              return const HomePage();
            } else {
              return const LoginPage();
            }
          }),
    );
  }

  void login(BuildContext context, String? email, String? uid) async {
    loadingUser = true;
    setFinishedLoadingState(false);
    await loginGoogle(context, email!, uid!);

    try {
      if (hasSelectedGroup) {
        currentTarget = await getUserData(await getCurrTargetUid(playerUID: uid, groupCode: selectedGroup.groupName));
      }
    } catch (E) {
      print(E);
    }

    setFinishedLoadingState(true);
    loadingUser = false;
  }
}
