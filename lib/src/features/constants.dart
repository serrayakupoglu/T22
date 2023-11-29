import 'package:flutter/material.dart';

const String kBaseUrl = "http://192.168.1.24:105";
const String kIconPath = 'lib/src/assets/my_icon.png';
const String kFontMetrisch = "Metrisch";
const double kHeaderMsgSize = 24;
const double kBodyMsgSize = 14;

// Opening Screen
const int kOpeningBG = 0xFF121212;
const int kOpeningButtonBG = 0xFF57B65F;
const double kOpeningIconTopMargin = 153;
const double kOpeningIconHeight = 170;
const double kOpeningIconWidth = 192.06;
const double kOpeningButtonBottomMargin = 20;
const double kOpeningButtonSideMargin = 15;
const double kOpeningButtonSidePadding = 16;
const double kOpeningButtonVerticalPadding = 16;
const double kOpeningButtonWidth = 379;
const double kOpeningButtonHeight = 53;
const double kOpeningButtonRadius = 22;
const double kOpeningButtonBorderWidth = 1;
const String kOpeningButtonSignInText = "Sign In";
const String kOpeningButtonSignUpText = "Sign Up";
const Color kOpeningButtonTextColor = Colors.white;


// Sign In Page
const int kInvalidCredentialsCode = 401;
const int kMissingCredentialsCode = 400;
const int kAlreadyLoggedInCode = 402;
const int kSuccessCode = 200;
const String kInvalidCredentialsMsg = 'Invalid username or password';
const String kMissingCredentialsMsg = 'Missing Credentials';
const String kAlreadyLoggedInMsg = 'User Already Logged In';

const int kAppBarColor = 0xFF131316;
const double kAppBarTextFontSize = 16;
const String kAppBarText = "Sign In";

const int kSignInPageBG = 0xFF131316;
const String kSignInPageHeaderMsg = "Welcome!";
const String kSignInPageBodyMsg = "Speak Friend and Enter";
const String kSignInPageUserNameInputText = "User Name";
const String kSignInPagePasswordInputText = "Password";
const double kSignInPageSideMargin = 16;
const double kSignInPageInputTextSize = 14;
const double kSignInPageForgotPassTextSize = 14;
const String kSignInPageForgotPassText = "Forgot My Password";
const int kSignInPageForgotPassTextColor = 0xFF57B65F;


// InputButton
const int kInputButtonColor = 0xFF292A38;
const int kInputButtonTextColor = 0xFF686C7E;
const double kInputButtonBorder = 8;
const double kInputButtonPadding = 8;
const double kInputTextSize = 12;

//Sign Up
const int kSignUpPageBG = 0xFF121212;
const String kSignUpAppBarText = "Sign Up";
const String kSignUpNameText = "Name";
const String kSignUpSurnameText = "Surname";
const String kSignUpEmailText = "Email";
const String kSignUpUsernameText = "Username";
const String kSignUpPasswordText = "Password";
const String kSignUpBodyText = "Just a few seconds to Sign Up";
const int kPasswordsDoNotMatchCode = 400;
const int kUserAlreadyExistsCode = 401;
const String kUserAlreadyExistsMsg = "User Already Exists";
const String kPasswordsDoNotMatchMsg = "Passwords do not match";

// Forgot Pass
const String kForgotPassAppBarText = "Forgot Password";
const String kForgotPassHeaderText = "Verification";
const String kForgotPassBodyText = "Please enter you e-mail to change your password";
const String kForgotPassButtonText = "Send";
const String kForgotPassCodeHeaderText = "Verification Code";
const int kForgotPassBG = 0xFF131316;