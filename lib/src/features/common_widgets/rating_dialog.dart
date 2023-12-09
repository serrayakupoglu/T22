import 'package:flutter/material.dart';
import 'package:untitled1/src/features/controller/song_controller.dart';
import 'package:untitled1/src/features/models/song.dart';

class RatingDialog extends StatefulWidget {
  final Song song;

  const RatingDialog({Key? key, required this.song}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _userRating = 0;
  late SongController controller;
  @override
  void initState() {
    super.initState();
    controller = SongController(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rate "${widget.song.songName}"',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              activeColor: Colors.green,
              value: _userRating,
              onChanged: (newRating) {
                setState(() {
                  _userRating = newRating;
                });
              },
              min: 0,
              max: 10,
              divisions: 10,
              label: '$_userRating',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                await controller.rateSong(widget.song.songName, _userRating.toInt());
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
