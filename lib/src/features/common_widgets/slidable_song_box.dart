import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:untitled1/src/features/common_widgets/song_box.dart';

class SlidableSongBoxPlaylist extends StatefulWidget{

  final Widget child;

  final SlidableActionCallback?  removeButtonFunction;


  const SlidableSongBoxPlaylist({super.key, required this.child, required this.removeButtonFunction});

  @override
  State<StatefulWidget> createState() => _SlidableSongBoxPlaylistState();

}

class _SlidableSongBoxPlaylistState extends State<SlidableSongBoxPlaylist>{
  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        extentRatio: 0.15,
        motion: const BehindMotion(),
        children: [
          SlidableAction(

            backgroundColor: Colors.red,
            icon: Icons.remove,
            onPressed: widget.removeButtonFunction
          ),
        ],
      ),
      child: widget.child,
    );
  }

}