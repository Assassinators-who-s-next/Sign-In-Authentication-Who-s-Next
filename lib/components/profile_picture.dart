import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final int radius;
  final String imagePath;
  final VoidCallback onClicked;

  const ProfilePicture({
    Key? key,
    required this.radius,
    required this.imagePath,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return circularImage();
  }

  Widget circularImage() {       
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: NetworkImage(imagePath),
          fit: BoxFit.cover,
          width: radius as double,
          height: radius as double,
          child: InkWell(onTap: onClicked),
        ),
      ),
    );
  }
}