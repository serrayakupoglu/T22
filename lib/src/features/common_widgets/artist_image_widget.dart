import 'package:flutter/material.dart';
import 'package:untitled1/src/features/constants.dart';

class CircularImageFromUrlWidget extends StatelessWidget {
  final String artistName;
  final double imageSize;

  const CircularImageFromUrlWidget({Key? key, required this.artistName, this.imageSize = 40.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: imageSize,
      height: imageSize,
      child: ClipOval(
        child: Image.network(
          '${kBaseUrl}/get_artist_image/$artistName',
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}