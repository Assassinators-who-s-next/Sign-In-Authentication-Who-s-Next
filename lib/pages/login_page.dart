import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:basic_auth/components/my_button.dart';
import 'package:basic_auth/components/my_textfield.dart';
import 'package:basic_auth/components/square_tile.dart';
import 'package:basic_auth/networking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // sign in user method
  void signUserIn() async {
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
        email: emailController.text,
        password: passwordController.text,
      );
      // pop off loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop off loading circle
      Navigator.pop(context);

      // incorrect user name
      showErrorMessage(e.code);
    }
  }

  // error message for log in
  void showErrorMessage(String message) {
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

  void incorrectPasswordMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(title: Text('Incorrect Password'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],

        // safe area ignores 'notch area' on different phone shapes
        body: SafeArea(
            child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                const SizedBox(height: 50),
                const Icon(
                  Icons.face_rounded,
                  size: 100,
                ),
                const SizedBox(height: 50),

                // welcome back
                Text(
                  'Who\'s Next?',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 50),

                // username
                MyTextField(
                  controller: emailController,
                  hintText: "username",
                  obscureText: false,
                ),
                const SizedBox(height: 15),

                // password
                MyTextField(
                  controller: passwordController,
                  hintText: "password",
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                // forgot password STILL NEED FUNCTIONALITY
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // sign in button
                MyButton(
                  onTap: () => signUserIn(),
                ),
                const SizedBox(height: 50),

                // or sign in with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[400],
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          ' or sign in with ',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                        color: Colors.grey[400],
                        thickness: 1.5,
                      ))
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // google/apple sign in button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // google button
                    SquareTile(
                      onTap: () => AuthService().signInWithGoogle(),
                      imagePath: 'lib/images/google-logo.png',
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // not a member? register here
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Not a member?'),
                    SizedBox(width: 4),
                    Text(
                      'Register here',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )));
  }
}
