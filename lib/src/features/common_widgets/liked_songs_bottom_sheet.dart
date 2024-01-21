import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/rating_dialog.dart';
import 'package:untitled1/src/features/models/song.dart';

class LikedSongBottomSheet extends StatefulWidget {

  final Map<dynamic, dynamic> song;
  final VoidCallback? likeSongFunction;
  final VoidCallback? addSongFunction;
  const LikedSongBottomSheet({super.key, required this.song, this.likeSongFunction, this.addSongFunction});



  @override
  State<StatefulWidget> createState() => _LikedSongBottomSheetState();

}

class _LikedSongBottomSheetState extends State<LikedSongBottomSheet>{


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 5),
          child: Text('Liked At: ${widget.song['liked_at'].day.toString().padLeft(2, '0')}/'
              '${widget.song['liked_at'].month.toString().padLeft(2, '0')}/'
              '${widget.song['liked_at'].year.toString()}'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: widget.likeSongFunction,
              icon: Icon(Icons.favorite),
            ),

            IconButton(
                onPressed: () {
                  Song song = Song(albumId: '', albumName: '', artists: [], songName: widget.song['song'], popularity: 0, );
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RatingDialog(song: song);
                    },
                  );
                },
                icon: const Icon(Icons.star_rate)
            ),

            IconButton(onPressed: widget.addSongFunction, icon: const Icon(Icons.add))
          ],
        )
      ],
    );
  }
}