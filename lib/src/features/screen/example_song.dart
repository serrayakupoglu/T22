import 'package:flutter/material.dart';
import 'package:untitled1/src/features/controller/song_controller.dart';
import 'package:untitled1/src/features/service/example_song_service.dart';

class SongScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SongScreenState();

}

class _SongScreenState extends State<SongScreen> {

  @override
  Widget build(BuildContext context) {
    final SongController _controller = SongController(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () async {
        _controller.search('Umbrella');
      },

      ),
      body: Container(

      ),
    );
  }

}