import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class RecommendedSongSlidable extends StatefulWidget {
  const RecommendedSongSlidable({super.key, this.rateButtonFunction, required this.child, this.addButtonFunction, this.likeButtonFunction});
  final SlidableActionCallback?  rateButtonFunction;
  final SlidableActionCallback?  addButtonFunction;
  final SlidableActionCallback?  likeButtonFunction;
  final Widget child;
  @override
  State<StatefulWidget> createState() => _RecommendedSongSlidableBoxState();

}

class _RecommendedSongSlidableBoxState extends State<RecommendedSongSlidable>{
  @override
  Widget build(BuildContext context) {
    return Slidable(
      startActionPane: ActionPane(
        extentRatio: 0.5,
        motion: BehindMotion(),
        children: [
          SlidableAction(
              backgroundColor: Colors.green,
              icon: Icons.favorite,
              onPressed: widget.likeButtonFunction
          ),
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

      child: widget.child,
    );
  }
}