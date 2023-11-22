import 'package:flutter/material.dart';
import '../constants.dart';

class BodyText extends StatelessWidget {

  final String msg;

  const BodyText({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Text(
      msg,
      style: const TextStyle(
        fontSize: kBodyMsgSize,
        color: Colors.white,
        fontFamily: kFontMetrisch,
      ),
    );
  }

}