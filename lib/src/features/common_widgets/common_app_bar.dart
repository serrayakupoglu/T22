import 'package:flutter/material.dart';
import '../constants.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget{
  final String appBarText;
  final bool canGoBack;

  const CommonAppBar({super.key, required this.appBarText, required this.canGoBack});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: canGoBack,
      centerTitle: true,
      backgroundColor: const Color(kAppBarColor),
      title: Text(
        appBarText,
        style: const TextStyle(
            fontFamily: kFontMetrisch,
            fontSize: kAppBarTextFontSize
        ),
      ),
    );
  }
  static final _appBar = AppBar();
  @override
  Size get preferredSize => _appBar.preferredSize;

}