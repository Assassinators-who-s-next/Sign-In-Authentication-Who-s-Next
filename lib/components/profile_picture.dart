import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final double radius;
  final String imagePath;
  final bool isNetworkPath;
  final VoidCallback onClicked;

  const ProfilePicture({
    Key? key,
    required this.radius,
    required this.imagePath,
    required this.isNetworkPath,
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
          image: isNetworkPath
              //? NetworkImage(imagePath)
              ? Image.network(imagePath).image
              : Image.asset(imagePath).image,
          fit: BoxFit.cover,
          width: radius,
          height: radius,
          child: InkWell(onTap: onClicked),
        ),
      ),
    );
  }
}
