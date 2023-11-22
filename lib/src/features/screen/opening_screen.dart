import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/src/features/constants.dart';
import 'package:untitled1/src/features/controller/opening_controller.dart';


class OpeningPage extends StatelessWidget {
  const OpeningPage({super.key});


  @override
  Widget build(BuildContext context) {
    final OpeningScreenController controller = OpeningScreenController(context);
    return Scaffold(
      backgroundColor: const Color(kOpeningBG),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.only(top: kOpeningIconTopMargin),
              child: const Image(image: AssetImage(kIconPath),
                width: kOpeningIconWidth, height: kOpeningIconHeight,
              ),
            ),
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    bottom: kOpeningButtonBottomMargin,
                    left: kOpeningButtonSideMargin,
                    right: kOpeningButtonSideMargin,
                  ),
                  child: ElevatedButton(
                    onPressed: controller.navigateToSignIn,
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
                Container(
                  margin: const EdgeInsets.only(
                    bottom: kOpeningButtonBottomMargin,
                    left: kOpeningButtonSideMargin,
                    right: kOpeningButtonSideMargin,
                  ),
                  child: ElevatedButton(
                    onPressed: controller.navigateToSignUp,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(kOpeningButtonSidePadding, kOpeningButtonVerticalPadding, kOpeningButtonSidePadding, kOpeningButtonVerticalPadding),
                        backgroundColor: const Color(kOpeningBG),
                        fixedSize: const Size(kOpeningButtonWidth, kOpeningButtonHeight),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Color(kOpeningButtonBG), width: kOpeningButtonBorderWidth),
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
                )
              ],
            )
          ],
        ),
    );
  }

}