import 'package:flutter/material.dart';
import '../constants.dart';

class ForgotPassCodeBox extends StatefulWidget {

  final TextEditingController controller;


  const ForgotPassCodeBox({super.key, required this.controller});

  @override
  State<StatefulWidget> createState() => _ForgotPassCodeBoxState();

}

class _ForgotPassCodeBoxState extends State<ForgotPassCodeBox>{
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextField(
        style: const TextStyle(
            color: Colors.white,
            fontSize: kInputTextSize,
            decorationThickness: 0
        ),
        controller: widget.controller,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(kInputButtonPadding),
            fillColor: const Color(kInputButtonColor),
            filled: true,
            border: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(kInputButtonBorder),
                borderSide: const BorderSide(
                    width: 0,
                    style: BorderStyle.none
                )
            )
        ),
      ),
    );
  }

}