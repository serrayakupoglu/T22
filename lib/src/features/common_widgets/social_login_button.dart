import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {

  final String buttontext;
  final Color buttonColor;
  final Color textColor;
  final double radius;
  final double height;
  final Widget buttonIcon;
  final VoidCallback onPressed;

  const SocialLoginButton({super.key, required this.buttontext, required this.buttonColor, required this.textColor, required this.radius, required this.height, required this.buttonIcon, required this.onPressed});




  @override
  Widget build(BuildContext context) {

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius)
        )
      ),

      child: Text(
        buttontext,
        style: TextStyle(color: textColor),
      ),

    );

  }



}