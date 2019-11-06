import 'dart:ui' as ui;

import 'package:example/html/html.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:quiver/strings.dart';

typedef TapLinkCallback = void Function(
    String target, String media, String mimeType, String href);

typedef TapImageCallback = void Function(
    String src, double width, double height);

typedef TapVideoCallback = void Function(
    String poster, String src, double width, double height);

class HtmlTapCallbacks {
  HtmlTapCallbacks.all({
    this.onTapLink,
    this.onTapImage,
    this.onTapVideo,
  });

  final TapLinkCallback onTapLink;
  final TapImageCallback onTapImage;
  final TapVideoCallback onTapVideo;
}

typedef CustomRender = InlineSpan Function(
  Size window,
  HtmlParseContext context,
  String sourceUrl,
  dom.Node node,
  ParseNodes parseNodes,
  HtmlTapCallbacks callbacks,
);

typedef ParseNodes = void Function(
  HtmlParseContext context,
  List<dom.Node> nodes,
  List<InlineSpan> children,
);

class HtmlParseContext {
  HtmlParseContext.rootContext({
    double fontSize,
  })  : parent = null,
        textStyle = TextStyle(fontSize: fontSize),
        indentLevel = 0,
        condenseWhitespace = true;

  HtmlParseContext.nextContext(
    HtmlParseContext context, {
    @required this.parent,
    int indentLevel,
    TextStyle textStyle,
    bool condenseWhitespace,
  })  : assert(parent != null),
        textStyle = textStyle ?? context.textStyle,
        indentLevel = indentLevel ?? context.indentLevel,
        condenseWhitespace = condenseWhitespace ?? context.condenseWhitespace;

  HtmlParseContext.removeIndentContext(HtmlParseContext context)
      : parent = context.parent,
        textStyle = context.textStyle,
        indentLevel = 0,
        condenseWhitespace = context.condenseWhitespace;

  final InlineSpan parent;
  final TextStyle textStyle;
  final int indentLevel;
  final bool condenseWhitespace;
}

InlineSpan defaultImgRender(
  Size window,
  HtmlParseContext context,
  String sourceUrl,
  dom.Element node,
  ParseNodes parseNodes,
  HtmlTapCallbacks callbacks, {
  ImageProvider networkImage(String url, double width, double height),
}) {
  String src = node.attributes['src'];
  String alt = node.attributes['alt'];
  String align = node.attributes['align']; // 不支持 left/right
  String border = node.attributes['border'];
  String height = node.attributes['height'];
  String hspace = node.attributes['hspace'];
  String vspace = node.attributes['vspace'];
  String width = node.attributes['width'];
  ui.PlaceholderAlignment alignment;
  switch (align) {
    case 'top':
      alignment = ui.PlaceholderAlignment.top;
      break;
    case 'bottom':
      alignment = ui.PlaceholderAlignment.bottom;
      break;
    case 'middle':
      alignment = ui.PlaceholderAlignment.middle;
      break;
    case 'left':
    case 'right':
    default:
      alignment = ui.PlaceholderAlignment.bottom;
      break;
  }
  String srcValue = isNotEmpty(sourceUrl)
      ? Uri.tryParse(sourceUrl).resolve(src).toString()
      : src;
  double widthValue = Html.parseHtmlWH(width, window?.width);
  double heightValue = Html.parseHtmlWH(height, window?.height) ?? widthValue;
  Widget child;
  Uri uri = isNotEmpty(srcValue) ? Uri.tryParse(srcValue) : null;
  if (uri == null) {
    child = SizedBox(
      width: widthValue,
      height: heightValue,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Icon(
                  Icons.image,
                  color: Html.parseHtmlColor('gray'),
                ),
                Text.rich(TextSpan(
                  text: alt ?? '',
                  style: context.textStyle,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  } else {
    ImageProvider image;
    if (uri.data != null && uri.data.isBase64) {
      image = MemoryImage(uri.data.contentAsBytes());
    } else {
      image = networkImage?.call(srcValue, widthValue, heightValue) ??
          NetworkImage(srcValue);
    }
    child = Image(
      image: image,
      width: widthValue,
      height: heightValue,
      fit: BoxFit.fitWidth,
    );
  }
  return WidgetSpan(
    child: Container(
      padding: EdgeInsets.symmetric(
        vertical: Html.parseHtmlWH(vspace) ?? 0.0,
        horizontal: Html.parseHtmlWH(hspace) ?? 0.0,
      ),
      decoration: Html.parseHtmlWH(border) != null
          ? ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: Html.parseHtmlWH(border) ?? 0.0),
              ),
            )
          : null,
      child: GestureDetector(
        onTap: () {
          callbacks.onTapImage?.call(srcValue, widthValue, heightValue);
        },
        child: child,
      ),
    ),
    alignment: alignment,
  );
}

InlineSpan defaultVideoRender(
  Size window,
  HtmlParseContext context,
  String sourceUrl,
  dom.Element node,
  ParseNodes parseNodes,
  HtmlTapCallbacks callbacks, {
  Widget posterRender(String poster, double width, double height),
}) {
  String height = node.attributes['height'];
  String poster = node.attributes['poster'];
  String src = node.attributes['src'];
  String width = node.attributes['width'];
  String posterValue = isNotEmpty(sourceUrl)
      ? Uri.tryParse(sourceUrl).resolve(poster).toString()
      : poster;
  String srcValue = isNotEmpty(sourceUrl)
      ? Uri.tryParse(sourceUrl).resolve(src).toString()
      : src;
  double widthValue = Html.parseHtmlWH(width, null);
  double heightValue = Html.parseHtmlWH(height, null);
  Widget child = posterRender?.call(posterValue, widthValue, heightValue) ??
      defaultPosterRender(posterValue, widthValue, heightValue);
  return WidgetSpan(
    child: GestureDetector(
      onTap: () {
        callbacks.onTapVideo
            ?.call(posterValue, srcValue, widthValue, heightValue);
      },
      child: child,
    ),
  );
}

Widget defaultPosterRender(
  String poster,
  double width,
  double height, {
  ImageProvider networkImage(String url, double width, double height),
}) {
  Widget child;
  Uri uri = isNotEmpty(poster) ? Uri.tryParse(poster) : null;
  if (uri == null) {
    child = const Text.rich(TextSpan(text: 'video'));
  } else {
    ImageProvider image;
    if (uri.data != null && uri.data.isBase64) {
      image = MemoryImage(uri.data.contentAsBytes());
    } else {
      image = networkImage?.call(poster, width, height) ?? NetworkImage(poster);
    }
    child = Image(
      image: image,
      width: width,
      height: height,
    );
  }
  return child;
}
