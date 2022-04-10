import 'package:flutter/material.dart';

class VideoBanner extends StatelessWidget {
  final String avatarUrl;
  final String rowTitle;
  final String rowDes;
  final Widget slotChild;
  final bool isAssets;
  const VideoBanner({
    Key? key,
    required this.avatarUrl,
    required this.rowTitle,
    required this.rowDes,
    required this.slotChild,
    this.isAssets = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: ClipOval(
                child: FadeInImage(
                  fadeOutDuration: const Duration(milliseconds: 50),
                  fadeInDuration: const Duration(milliseconds: 50),
                  placeholder: const AssetImage('images/movie-lazy.gif'),
                  image: isAssets
                      ? const AssetImage('images/author-default.jpg')
                      : NetworkImage(avatarUrl) as ImageProvider,
                  imageErrorBuilder: (context, obj, trace) {
                    return Image.asset('images/author-default.jpg');
                  },
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rowTitle,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  rowDes,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.black54,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: slotChild,
          ),
        ],
      ),
    );
  }
}
