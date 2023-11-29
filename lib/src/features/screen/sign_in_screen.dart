import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/body_text.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/common_widgets/error_text.dart';
import 'package:untitled1/src/features/common_widgets/header_text.dart';
import 'package:untitled1/src/features/common_widgets/input_text_box.dart';
import '../controller/sing_in_controller.dart';
import 'package:untitled1/src/features/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  @override
  Widget build(BuildContext context) {
    SignInScreenController controller = SignInScreenController(context);
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    Color errorTextColor = Colors.white;
    bool isError = false;
    return Scaffold(
      backgroundColor: const Color(kSignInPageBG),
      resizeToAvoidBottomInset: false,
      appBar: const CommonAppBar(appBarText: kAppBarText),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.only(left: kSignInPageSideMargin, right: kSignInPageSideMargin, top: kSignInPageSideMargin),
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.only(bottom: kSignInPageSideMargin),
                  child: HeaderText(msg: kSignInPageHeaderMsg),
                ),
                const Padding(padding: EdgeInsets.only(bottom: kSignInPageSideMargin),
                  child: BodyText(msg: kSignInPageBodyMsg),
                ),
                Padding(padding: const EdgeInsets.only(bottom: kSignInPageSideMargin),
                  child: InputBox(innerText: kSignInPageUserNameInputText, controller: emailController, isObscure: false)
                ),
                Padding(padding: const EdgeInsets.only(bottom: kSignInPageSideMargin),
                    child: InputBox(innerText: kSignInPagePasswordInputText, controller: passwordController, isObscure: true)
                ),
                Padding(padding: const EdgeInsets.only(bottom: kSignInPageSideMargin),
                    child: ErrorText(msg: "ErrorMsg", clr: errorTextColor)
                ),
                Text("Kemal", style: TextStyle(color: isError ? Colors.red : Colors.white),),
                Container(
                  alignment: Alignment.centerRight,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: kSignInPageForgotPassTextSize,
                          color: Color(kSignInPageForgotPassTextColor),
                          fontWeight: FontWeight.bold,
                          fontFamily: kFontMetrisch
                      ),
                      text: kSignInPageForgotPassText,
                      recognizer: TapGestureRecognizer()
                        ..onTap = controller.navigateToForgotPass,
                    ),
                  ),
                )
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.only(
              bottom: kOpeningButtonBottomMargin,
              left: kOpeningButtonSideMargin,
              right: kOpeningButtonSideMargin,
            ),
            child: ElevatedButton(
              onPressed: () async => {
                if (isError = await controller.signIn(emailController.text, passwordController.text)) {
                  setState(() {
                    print(isError);
                  })
                }
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(kOpeningButtonSidePadding, kOpeningButtonVerticalPadding, kOpeningButtonSidePadding, kOpeningButtonVerticalPadding),
                  backgroundColor: const Color(kOpeningButtonBG),
                  fixedSize: const Size(kOpeningButtonWidth, kOpeningButtonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kOpeningButtonRadius),
                  )
              ),
              child: const Text(
                kOpeningButtonSignInText,
                style: TextStyle(
                    color: kOpeningButtonTextColor,
                    fontFamily: kFontMetrisch
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

}