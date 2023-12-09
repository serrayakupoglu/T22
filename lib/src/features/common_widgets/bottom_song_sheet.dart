import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/rating_dialog.dart';
import 'package:untitled1/src/features/models/song.dart';

class BottomSongSheet extends StatefulWidget {

  final Song song;
  const BottomSongSheet({super.key, required this.song});

  @override
  State<StatefulWidget> createState() => _BottomSongSheetState();

}

class _BottomSongSheetState extends State<BottomSongSheet>{
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.all(16),
            child: Text("Song: ${widget.song.songName}"),
          ),
          Container(
            margin: EdgeInsets.all(16),
            child: Text("Artists: ${widget.song.getConcatenatedArtistNames()}"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.add),
              ),
              IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return RatingDialog(song: widget.song); // Pass the song object to the rating dialog
                      },
                    );
                  },
                  icon: Icon(Icons.star_rate)),
              IconButton(onPressed: (){}, icon: Icon(Icons.info_outline))
            ],
          )
        ],
      ),
    );
  }
}