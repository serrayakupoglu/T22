import 'package:flutter/material.dart';

import '../constants.dart';

class AnalysisBox extends StatefulWidget {
  final String innerText;
  final VoidCallback? onIconPressed;
  const AnalysisBox({super.key, required this.innerText, this.onIconPressed});

  @override
  State<StatefulWidget> createState() => _AnalysisBoxState();

}

class _AnalysisBoxState extends State<AnalysisBox>{
  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(kSearchBoxColor),
        padding: const EdgeInsets.only(left: kSearchBoxPadding, right: kSearchBoxPadding, top: kSearchBoxPadding / 2, bottom: kSearchBoxPadding / 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Container(
              margin: const EdgeInsets.only(bottom: kSearchBoxMarginBetweenText),
              child: Text(
                widget.innerText,
                style: const TextStyle(
                  color: kSearchSongNameColor,
                  fontWeight: FontWeight.w400,
                  fontFamily: kFontMetrisch,
                ),
              ),
            )
            ),
            IconButton(
                onPressed: widget.onIconPressed,
                splashColor: Colors.transparent,
                icon: const Icon(
                  Icons.more_horiz,
                  color: Color(kSearchBoxMoreIconColor),
                )
            )
          ],
        )
    );
  }
}