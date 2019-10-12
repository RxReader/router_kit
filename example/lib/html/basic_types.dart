import 'dart:ui' as ui;

import 'package:csslib/parser.dart' as css_parser;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:html/dom.dart' as dom;
import 'package:quiver/strings.dart';

typedef TapLinkCallback = void Function(
  String target,
  String media,
  String mimeType,
  String href,
);

typedef TapImageCallback = void Function(
  String src,
  double width,
  double height,
);

typedef TapVideoCallback = void Function(
  String poster,
  String src,
  double width,
  double height,
);

class HtmlParseContext {
  final int indentLevel;
  final TextStyle textStyle;

  HtmlParseContext.rootContext({
    double fontSize,
  })  : indentLevel = 0,
        textStyle = TextStyle(fontSize: fontSize);

  HtmlParseContext.nextContext(
    HtmlParseContext context, {
    int indentLevel,
    TextStyle textStyle,
  })  : indentLevel = indentLevel ?? context.indentLevel,
        textStyle = textStyle ?? context.textStyle;

  HtmlParseContext.removeIndentContext(HtmlParseContext context)
      : indentLevel = 0,
        textStyle = context.textStyle;
}

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
  dom.Node node,
  ChildrenRender childrenRender,
  HtmlTapCallbacks callbacks,
);

typedef ChildrenRender = List<InlineSpan> Function(
  HtmlParseContext context,
  List<dom.Node> nodes,
);

const Map<String, Color> _htmlColorNameMap = <String, Color>{
  'aqua': Color(0xFF00FFFF),
  'black': Colors.black,
  'blue': Color(0xFF0000FF),
  'fuchsia': Color(0xFFFF00FF),
  'gray': Color(0xFF888888),
  'green': Color(0xFF00FF00),
  'lime': Color(0xFF00FF00),
  'maroon': Color(0xFF800000),
  'navy': Color(0xFF000080),
  'olive': Color(0xFF808000),
  'purple': Color(0xFF800080),
  'red': Color(0xFFFF0000),
  'silver': Color(0xFFC0C0C0),
  'teal': Color(0xFF008080),
  'white': Colors.white,
  'yellow': Color(0xFFFFFF00),
};

Color parseHtmlColor(String color) {
  Color htmlColor = _htmlColorNameMap[color];
  if (htmlColor == null) {
    css_parser.Color parsedColor = css_parser.Color.css(color);
    htmlColor = Color(parsedColor.argbValue);
  }
  return htmlColor;
}

double parseHtmlWH(String value, double refValue) {
  if (isNotEmpty(value)) {
    if (value.endsWith('%')) {
      value = value.replaceAll('%', '');
      return refValue != null && double.tryParse(value) != null
          ? double.tryParse(value) * refValue
          : null;
    } else {
      value = value.toLowerCase().replaceAll('px', '');
      return double.tryParse(value);
    }
  }
  return null;
}

InlineSpan imageRender(
  Size window,
  HtmlParseContext context,
  dom.Node node,
  ChildrenRender childrenRender,
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
  Uri uri = isNotEmpty(src) ? Uri.tryParse(src) : null;
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
  double widthValue = parseHtmlWH(width, window?.width);
  double heightValue = parseHtmlWH(height, window?.height) ?? widthValue;
  Widget child;
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
                  color: _htmlColorNameMap['gray'],
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
      image = networkImage?.call(uri.toString(), widthValue, heightValue) ??
          NetworkImage(uri.toString());
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
        vertical: parseHtmlWH(vspace, null) ?? 0.0,
        horizontal: parseHtmlWH(hspace, null) ?? 0.0,
      ),
      decoration: parseHtmlWH(border, null) != null
          ? ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: parseHtmlWH(border, null) ?? 0.0),
              ),
            )
          : null,
      child: GestureDetector(
        onTap: () {
          callbacks.onTapImage?.call(src, widthValue, heightValue);
        },
        child: child,
      ),
    ),
    alignment: alignment,
  );
}

InlineSpan videoRender(
  Size window,
  HtmlParseContext context,
  dom.Node node,
  ChildrenRender childrenRender,
  HtmlTapCallbacks callbacks, {
  Widget customPoster(String poster, double width, double height),
}) {
  String height = node.attributes['height'];
  String poster = node.attributes['poster'];
  String src = node.attributes['src'];
  String width = node.attributes['width'];
  double widthValue = parseHtmlWH(width, null);
  double heightValue = parseHtmlWH(height, null);
  Widget child = customPoster?.call(poster, widthValue, heightValue) ??
      defaultPost(poster, widthValue, heightValue);
  return WidgetSpan(
    child: GestureDetector(
      onTap: () {
        callbacks.onTapVideo?.call(poster, src, widthValue, heightValue);
      },
      child: child,
    ),
  );
}

Widget defaultPost(
  String poster,
  double width,
  double height, {
  ImageProvider networkImage(String url, double width, double height),
}) {
  Widget child;
  Uri uri = isNotEmpty(poster) ? Uri.tryParse(poster) : null;
  if (uri == null) {
    child = Text.rich(TextSpan(text: 'video'));
  } else {
    ImageProvider image;
    if (uri.data != null && uri.data.isBase64) {
      image = MemoryImage(uri.data.contentAsBytes());
    } else {
      image = NetworkImage(uri.toString());
    }
    child = Image(
      image: image,
      width: width,
      height: height,
    );
  }
  return child;
}
