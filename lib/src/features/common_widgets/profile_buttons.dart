import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {

  final String buttonText;
  final VoidCallback onPressed;

  const ProfileButton({super.key, required this.buttonText, required this.onPressed});


  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.fromLTRB(15, 0, 15, 20),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide.none
            ),
            backgroundColor: Colors.white10,
            padding: EdgeInsets.all(15)
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(buttonText),
        ),
      ),
    );

  }



}