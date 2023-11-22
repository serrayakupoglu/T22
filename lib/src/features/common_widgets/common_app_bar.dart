import 'package:flutter/material.dart';
import '../constants.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget{

  final String appBarText;

  const CommonAppBar({super.key, required this.appBarText});

  @override
  Widget build(BuildContext context) {
    return AppBar(
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