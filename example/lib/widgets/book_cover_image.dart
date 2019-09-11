import 'package:example/widgets/ok_http_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookCoverImage extends StatelessWidget {
  const BookCoverImage({
    Key key,
    @required this.url,
    this.onTap,
  }) : super(key: key);

  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double radius = 5.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0x22000000),
            blurRadius: 5,
          ),
        ],
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(
            children: <Widget>[
              FadeInImage(
                placeholder: AssetImage('images/placeholder_cover.png'),
                image: OkHttpImage(url),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              FlatButton(
                onPressed: onTap ?? () {},
                padding: EdgeInsets.zero,
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
