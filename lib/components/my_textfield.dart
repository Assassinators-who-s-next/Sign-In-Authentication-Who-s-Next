import 'package:async/async.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {

  final controller; // lets developer access what the user types in textField
  final String hintText;
  final bool obscureText;

  MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.grey
                        .shade400)), // focused border shows that user is in text field when they click into it
            fillColor: Colors.grey.shade200,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[600]),
            alignLabelWithHint: true),
      ),
    );
  }
}
