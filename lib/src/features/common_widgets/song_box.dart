import 'package:flutter/material.dart';

import '../constants.dart';

class SongBox extends StatelessWidget {
  final String songName;
  final String artistName;
  final VoidCallback? onIconPressed;

  const SongBox({super.key, required this.songName, required this.artistName, this.onIconPressed});


  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(kSearchBoxColor),
      padding: const EdgeInsets.only(left: kSearchBoxPadding, right: kSearchBoxPadding, top: kSearchBoxPadding / 2, bottom: kSearchBoxPadding / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: kSearchBoxMarginBetweenText),
                child: Text(
                  songName,
                  style: const TextStyle(
                    color: kSearchSongNameColor,
                    fontWeight: FontWeight.w400,
                    fontFamily: kFontMetrisch,
                  ),
                ),
              ),
              Text(
                artistName,
                style: const TextStyle(
                    color: Color(kSearchBoxArtistColor),
                    fontFamily: kFontMetrisch,
                    fontSize: kSearchBoxArtistTextSize
                ),
              ),
            ],
            ),
          ),
          IconButton(
              onPressed: onIconPressed,
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