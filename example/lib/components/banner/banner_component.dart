import 'package:example/widgets/book_cover_image.dart';
import 'package:example/widgets/transformer_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:router_annotation/router_annotation.dart';

part 'banner_component.component.dart';

@Component(
  routeName: '/banner',
)
class BannerComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BannerComponentState();
  }
}

class _BannerComponentState extends State<BannerComponent> {
  static const List<String> imageUrls = <String>[
    'https://qcdn.zhangzhongyun.com/covers/2054.png?imageView2/0/w/300/q/75',
    'https://qcdn.zhangzhongyun.com/covers/1513.png?imageView2/0/w/300/q/75',
    'https://qcdn.zhangzhongyun.com/covers/4148.png?imageView2/0/w/300/q/75',
    'https://qcdn.zhangzhongyun.com/covers/833.png?imageView2/0/w/300/q/75',
    'https://qcdn.zhangzhongyun.com/covers/993.png?imageView2/0/w/300/q/75',
    'https://qcdn.zhangzhongyun.com/covers/542.png?imageView2/0/w/300/q/75',
  ];

  PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.5);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              height: 142,
              child: TransformerPageView(
                controller: _controller,
                transformer: (
                  BuildContext context,
                  Axis scrollDirection,
                  bool reverse,
                  PageMetrics metrics,
                  int index,
                  Widget child,
                ) {
                  double scale;
                  final int currentPage = metrics != null
                      ? metrics.page.round()
                      : _controller.initialPage;
                  if (metrics != null && metrics.axis == Axis.horizontal) {
                    double value = metrics.page - index;
                    scale = (1 - (value.abs() * 0.4)).clamp(89.0 / 142.0, 1.0);
                  } else {
                    scale = index == currentPage ? 1.0 : 89.0 / 142.0;
                  }
                  return Transform.scale(
                    scale: scale,//index == currentPage ? 1.0 : 0.5,
                    child: child,
                  );
                },
                builder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      print('index: $index');
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: BookCoverImage(
                        url: imageUrls[index],
                        onTap: () {
                          print('imageUrl: ${imageUrls[index]}');
                        },
                      ),
                    ),
                  );
                },
                childCount: imageUrls.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
