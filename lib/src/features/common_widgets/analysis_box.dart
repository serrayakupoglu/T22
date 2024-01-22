import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';

import '../constants.dart';

class AnalysisBox extends StatefulWidget {
  final String headerText;
  final Widget innerWidget;
  const AnalysisBox({Key? key, required this.headerText, required this.innerWidget}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnalysisBoxState();
}

class _AnalysisBoxState extends State<AnalysisBox> {


  @override
  Widget build(BuildContext context) {
    return Container(
      color:  Colors.grey[800],
      padding: EdgeInsets.only(top: 10),
      child: ExpandablePanel(
        collapsed: const Text(''),
        header: Container(
          margin: EdgeInsets.all(8.0),
          child: Text(
            widget.headerText,
            style: const TextStyle(
              color: kSearchSongNameColor,
              fontWeight: FontWeight.w400,
              fontFamily: kFontMetrisch,
            ),
          ),
        ),
        expanded: Container(
          padding: const EdgeInsets.all(16.0),
          child: widget.innerWidget,
        ),

      ),
    );
  }
}