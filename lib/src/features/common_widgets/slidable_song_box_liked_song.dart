import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class LikedSongSlidableSongBox extends StatefulWidget {
  const LikedSongSlidableSongBox({super.key, this.removeButtonFunction, this.rateButtonFunction, required this.child, this.addButtonFunction});
  final SlidableActionCallback?  removeButtonFunction;
  final SlidableActionCallback?  rateButtonFunction;
  final SlidableActionCallback?  addButtonFunction;
  final Widget child;
  @override
  State<StatefulWidget> createState() => _LikedSongSlidableSongBoxState();

}

class _LikedSongSlidableSongBoxState extends State<LikedSongSlidableSongBox>{
  @override
  Widget build(BuildContext context) {
    return Slidable(
      startActionPane: ActionPane(
        extentRatio: 0.3,
        motion: BehindMotion(),
        children: [
          SlidableAction(
              backgroundColor: Colors.blue,
              icon: Icons.star_rate,
              onPressed: widget.rateButtonFunction
          ),
          SlidableAction(
              backgroundColor: Colors.lightGreenAccent,
              icon: Icons.add,
              onPressed: widget.addButtonFunction
          ),
        ],
      ),
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