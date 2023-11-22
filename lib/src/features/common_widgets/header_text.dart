import 'package:flutter/material.dart';
import '../constants.dart';

class HeaderText extends StatelessWidget {

  final String msg;

  const HeaderText({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Text(
      msg,
      style: const TextStyle(
        fontSize: kHeaderMsgSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: kFontMetrisch,
      ),
    );
  }

}