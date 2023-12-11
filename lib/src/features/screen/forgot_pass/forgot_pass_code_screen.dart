import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/body_text.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/common_widgets/forgot_pass_code_box.dart';
import 'package:untitled1/src/features/service/storage_service.dart';

import '../../common_widgets/header_text.dart';
import '../../common_widgets/input_text_box.dart';
import '../../constants.dart';

class ForgotPassCode extends StatefulWidget {
  const ForgotPassCode({super.key});

  @override
  State<StatefulWidget> createState() => _ForgotPassCodeState();


}

class _ForgotPassCodeState extends State<ForgotPassCode> {
  final TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(kForgotPassBG),
      appBar: const CommonAppBar(appBarText: kForgotPassAppBarText, canGoBack: true),
      body: Container(
          margin: const EdgeInsets.all(kSignInPageSideMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding (
                    padding: EdgeInsets.only(bottom: kSignInPageSideMargin*1.2),
                    child: HeaderText(msg: kForgotPassCodeHeaderText),
                  ),
                  Padding (
                    padding: EdgeInsets.only(bottom: kSignInPageSideMargin*1.2),
                    child: BodyText(msg: 'Please enter the code sended to ..'),
                  ),
                ],
              ),
              Row(

                children: [
                  Padding (
                      padding: const EdgeInsets.only(bottom: kSignInPageSideMargin*1.2, right: kSignInPageSideMargin*0.8),
                      child: ForgotPassCodeBox(controller: emailController)
                  ),
                  Padding (
                      padding: const EdgeInsets.only(bottom: kSignInPageSideMargin*1.2, right: kSignInPageSideMargin*0.8),
                      child: ForgotPassCodeBox(controller: emailController)
                  ),
                  Padding (
                      padding: const EdgeInsets.only(bottom: kSignInPageSideMargin*1.2, right: kSignInPageSideMargin*0.8),
                      child: ForgotPassCodeBox(controller: emailController)
                  ),
                  Padding (
                      padding: const EdgeInsets.only(bottom: kSignInPageSideMargin*1.2, right: kSignInPageSideMargin*0.8),
                      child: ForgotPassCodeBox(controller: emailController)
                  ),
                  Padding (
                      padding: const EdgeInsets.only(bottom: kSignInPageSideMargin*1.2, right: kSignInPageSideMargin*0.8),
                      child: ForgotPassCodeBox(controller: emailController)
                  ),
                  Padding (
                      padding: const EdgeInsets.only(bottom: kSignInPageSideMargin*1.2),
                      child: ForgotPassCodeBox(controller: emailController)
                  )
                ],
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
            onPressed: () async => { },
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