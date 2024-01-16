import 'package:flutter/material.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/models/user_cache.dart';
import 'package:untitled1/src/features/service/storage_service.dart';

class PlaylistCreationDialog extends StatelessWidget {

  const PlaylistCreationDialog({Key? key, required this.onSuccess}) : super(key: key);
  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context) {

    UserController controller = UserController(context: context);
    String newPlaylistName = '';

    return AlertDialog(
      title: const Text('Create New Playlist'),
      content: TextField(
        onChanged: (value) {
          newPlaylistName = value;
        },
        decoration: const InputDecoration(hintText: 'Enter Playlist Name'),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Create'),
          onPressed: () async {
            String? username = await storageService.readSecureData('username');
            await controller.createPlaylist(newPlaylistName).then((isSuccess) async {
              UserProfileCache.updatePlaylists('$username', newPlaylistName);
              if (isSuccess) {
                controller.updateUserProfile('$username');
                onSuccess();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Success'),
                      content: const Text('Playlist created successfully!'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop(); // Close the previous dialog
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Failed'),

                      actions: <Widget>[
                        TextButton(
                          child: Text('Retry'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop(); // Close the previous dialog
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            }
            );


          },
        ),
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
