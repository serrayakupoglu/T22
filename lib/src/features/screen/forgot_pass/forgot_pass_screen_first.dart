import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/body_text.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/screen/forgot_pass/forgot_pass_code_screen.dart';
import 'package:untitled1/src/features/service/storage_service.dart';

import '../../common_widgets/header_text.dart';
import '../../common_widgets/input_text_box.dart';
import '../../constants.dart';

class ForgotPass extends StatefulWidget {
  const ForgotPass({super.key});

  @override
  State<StatefulWidget> createState() => _ForgotPassState();


}

class _ForgotPassState extends State<ForgotPass> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    return Scaffold(
      backgroundColor: const Color(kForgotPassBG),
      appBar: const CommonAppBar(appBarText: kForgotPassAppBarText, canGoBack: true),
      body: Container(
          margin: const EdgeInsets.all(kSignInPageSideMargin),
          child: ListView(
            children: <Widget>[
              const Padding (
                padding: EdgeInsets.only(bottom: kSignInPageSideMargin*1.2),
                child: HeaderText(msg: kForgotPassHeaderText),
              ),
              const Padding (
                  padding: EdgeInsets.only(bottom: kSignInPageSideMargin*1.2),
                  child: BodyText(msg: kForgotPassBodyText),
              ),
              Padding (
                padding: const EdgeInsets.only(bottom: kSignInPageSideMargin*1.2),
                child: InputBox(controller: emailController, isObscure: false, innerText: kSignUpEmailText,)
              )
            ],
          )
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 1,
        color: Colors.transparent,
        child:  Container(
          margin: const EdgeInsets.fromLTRB(kOpeningButtonSideMargin,kOpeningButtonSideMargin,kOpeningButtonSideMargin,kOpeningButtonSideMargin*2),
          child: ElevatedButton(
            onPressed: () async => {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ForgotPassCode();
            }))
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
              kForgotPassButtonText,
              style: TextStyle(
                  color: kOpeningButtonTextColor,
                  fontFamily: kFontMetrisch
              ),
            ),
          ),
        ),
      ),
    );
  }

}