import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {

  final String imagePath;

  const SquareTile({
    super.key, 
    required this.imagePath
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8)),

      child: Image.asset(
        imagePath,
        height: 40,
      ),
    );
  }
}
