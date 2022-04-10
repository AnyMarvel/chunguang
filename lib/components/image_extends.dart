import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class ImageExends extends StatelessWidget {
  final String imgUrl;
  const ImageExends({
    Key? key,
    required this.imgUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      imgUrl,
      compressionRatio: 0.5,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      cache: true,
      loadStateChanged: (ExtendedImageState state) {
        if (state.extendedImageLoadState == LoadState.loading) {
          return Image.asset(
            "images/movie-lazy.gif",
            fit: BoxFit.fill,
          );
        } else if (state.extendedImageLoadState == LoadState.failed) {
          return Image.asset(
            "images/movie-lazy.gif",
            fit: BoxFit.fill,
          );
        } else {
          return null;
        }
      },
      fit: BoxFit.fill,
    );
  }
}
