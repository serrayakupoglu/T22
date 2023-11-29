import 'package:flutter/material.dart';
import '../constants.dart';

class ErrorText extends StatelessWidget {

  final String msg;
  final Color clr;

  const ErrorText({super.key, required this.msg, required this.clr});

  @override
  Widget build(BuildContext context) {
    return Text(
      msg,
      style: TextStyle(
        fontSize: kBodyMsgSize,
        color: clr,
        fontFamily: kFontMetrisch,
      ),
    );
  }

}