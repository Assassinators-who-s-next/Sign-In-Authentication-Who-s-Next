import 'package:flutter/material.dart';
import 'package:whos_next/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
            child: newLoginScreen(context)));
  }

  Widget newLoginScreen(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topCenter,
      child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            const Icon(
              Icons.face_rounded,
              size: 175,
            ),
            Text(
              'Who\'s Next?',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 40,
              ),
            ),
            const SizedBox(height: 50),
            googleButton(context)
          ])),
    );
  }

  Widget googleButton(BuildContext context) {
    return GestureDetector(
      onTap: () => AuthService().signInWithGoogle(),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: const Color.fromARGB(255, 224, 47, 47)),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * .6,
          height: 45,
          child: Stack(children: [
            const Center(
                child: Text("Sign in with Google",
                    style: TextStyle(color: Colors.white))),
            Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Image.asset("lib/images/google-logo-red.png"),
                )),
          ]),
        ),
      ),
    );
  }
/*
  Widget oldLoginScreen(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
          child: Column(
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
            onTap: () => AuthService().signInWithEmailPassword(
                emailController.text, passwordController.text),
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
          googleButton(context),
          /*
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
          */

          const SizedBox(height: 25),
          /*
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.purple, // background color
              onPrimary: Colors.white, // foreground color
              shadowColor: Colors.purple, // elevation color
              elevation: 5, // elevation of button
            ),
            onPressed: () => {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JoinCreatePage(),
                  ))
            },
            child: const Text('debug: -> joingamepage',
                style: (TextStyle(fontSize: 10.0))),
          ),
          
          const SizedBox(height: 25),
          */

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
      )),
    );
  }
*/
}
