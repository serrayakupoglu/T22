import 'package:flutter/material.dart';
import '../constants.dart';

class InputBox extends StatefulWidget {

  final String innerText;
  final TextEditingController controller;
  final bool isObscure;

  const InputBox({super.key, required this.innerText, required this.controller, required this.isObscure});

  @override
  State<StatefulWidget> createState() => _InputBoxState();

}

class _InputBoxState extends State<InputBox>{
  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: widget.isObscure,
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

          labelText: widget.innerText,
          labelStyle: const TextStyle(
              fontSize: kSignInPageInputTextSize,
              color: Color(kInputButtonTextColor)
          ),
          border: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(kInputButtonBorder),
              borderSide: const BorderSide(
                  width: 0,
                  style: BorderStyle.none
              )
          )
      ),
    );
  }

}