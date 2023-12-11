import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/input_text_box.dart';
import 'package:untitled1/src/features/controller/song_controller.dart';

import '../constants.dart';
import '../models/song_input.dart';

class SongInputPage extends StatefulWidget {
  const SongInputPage({Key? key}) : super(key: key);

  @override
  State<SongInputPage> createState() => _SongInputPageState();
}

class _SongInputPageState extends State<SongInputPage> {
  late SongController songController;
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController popularityController = TextEditingController();
  final TextEditingController albumIdController = TextEditingController();
  final TextEditingController albumNameController = TextEditingController();
  final TextEditingController releaseDateController = TextEditingController();
  final TextEditingController artistIdController = TextEditingController();
  final TextEditingController artistNameController = TextEditingController();

  @override
  void initState() {
    songController = SongController(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView(
        children: [
          InputBox(
            controller: nameController,
            innerText: 'Song Name',
            isObscure: false,
          ),
          SizedBox(height: 10),
          InputBox(
            controller: durationController,
            innerText: 'Duration (ms)',
           isObscure: false,
          ),

          SizedBox(height: 10),

          InputBox(
            controller: albumNameController,
            innerText: 'Album Name',
            isObscure: false,
          ),
          SizedBox(height: 10),
          InputBox(
            controller: releaseDateController,
            innerText: 'Release Date',
            isObscure: false,
          ),
          SizedBox(height: 10),

          InputBox(
            controller: artistNameController,
            innerText: 'Artist Name',
            isObscure: false,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(kOpeningButtonSidePadding, kOpeningButtonVerticalPadding, kOpeningButtonSidePadding, kOpeningButtonVerticalPadding),
                backgroundColor: const Color(kOpeningButtonBG),
                fixedSize: const Size(kOpeningButtonWidth, kOpeningButtonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kOpeningButtonRadius),
                )
            ),
            onPressed: () async {
              final songData = SongData(
                id: '0',
                name: nameController.text,
                durationMs: int.tryParse(durationController.text) ?? 0,
                popularity: int.tryParse(popularityController.text) ?? 0,
                album: {
                  'id': '0',
                  'name': albumNameController.text,
                  'release_date': releaseDateController.text,
                },
                artists: [
                  {
                    'id': '0',
                    'name': artistNameController.text,
                  }
                ],
              );
              final response = await songController.addSongManually(songData);

              Future.delayed(Duration.zero, () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(response ? 'Success' : 'Error'),
                      content: Text(response ? 'Song is successfully added to the database.' : 'Song cannot be added.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              });

            },
            child: Text('Save Song'),
          ),
        ],
      ),
    );
  }
}
