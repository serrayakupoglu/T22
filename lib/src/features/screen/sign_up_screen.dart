import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/body_text.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/common_widgets/header_text.dart';
import 'package:untitled1/src/features/common_widgets/input_text_box.dart';
import 'package:untitled1/src/features/constants.dart';
import 'package:untitled1/src/features/controller/sign_up_controller.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {


  @override
  Widget build(BuildContext context) {
    final SignUpController controller = SignUpController(context: context);
    final TextEditingController emailController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController surnameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController password2Controller = TextEditingController();
    final TextEditingController userNameController = TextEditingController();
    return Scaffold(
      backgroundColor: const Color(kSignUpPageBG),
      resizeToAvoidBottomInset: false,
      appBar: const CommonAppBar(appBarText: kSignUpAppBarText, canGoBack: true),

      body: Container(
        margin: const EdgeInsets.all(kSignInPageSideMargin),
        child: ListView(
          children: <Widget>[
            const Padding (
              padding: EdgeInsets.only(bottom: kSignInPageSideMargin*1.2),
              child: HeaderText(msg: kSignInPageHeaderMsg),
            ),
            const Padding (
              padding: EdgeInsets.only(bottom: kSignInPageSideMargin*1.2),
              child: BodyText(msg: kSignUpBodyText)
            ),
            Padding (
              padding: const EdgeInsets.only(bottom: kSignInPageSideMargin*1.2),
              child: InputBox(controller: nameController,innerText: kSignUpNameText, isObscure: false),
            ),
            Padding (
              padding: const EdgeInsets.only(bottom: kSignInPageSideMargin*1.2),
              child: InputBox(controller: surnameController,innerText: kSignUpSurnameText, isObscure: false),
            ),
            Padding (
              padding: const EdgeInsets.only(bottom: kSignInPageSideMargin*1.2),
              child: InputBox(controller: emailController,innerText: kSignUpEmailText, isObscure: false),
            ),
            Padding (
              padding: const EdgeInsets.only(bottom: kSignInPageSideMargin*1.2),
              child: InputBox(controller: userNameController,innerText: kSignUpUsernameText, isObscure: false),
            ),
            Padding (
              padding: const EdgeInsets.only(bottom: kSignInPageSideMargin*1.2),
              child: InputBox(controller: passwordController,innerText: kSignUpPasswordText, isObscure: true),
            ),
            Padding (
              padding: const EdgeInsets.only(bottom: kSignInPageSideMargin*1.2),
              child: InputBox(controller: password2Controller,innerText: kSignUpPasswordText, isObscure: true),
            ),
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
                controller.signUp(userNameController.text, passwordController.text, password2Controller.text, nameController.text, surnameController.text, emailController.text)
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
                kOpeningButtonSignUpText,
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
