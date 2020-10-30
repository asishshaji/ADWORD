import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircularUserAvatar extends StatelessWidget {
  final double size;
  final String imageurl;

  const CircularUserAvatar({Key key, this.size, this.imageurl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        image: new DecorationImage(
          fit: BoxFit.cover,
          image: new CachedNetworkImageProvider(imageurl),
        ),
      ),
    );
  }
}
