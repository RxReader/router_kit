import 'package:flutter/widgets.dart';

class CountDownTimer extends StatefulWidget {
  const CountDownTimer({
    Key key,
    this.duration,
    this.builder,
  }) : super(key: key);

  final Duration duration;
  final Widget Function(BuildContext context, Duration duration) builder;

  @override
  State<StatefulWidget> createState() {
    return _CountDownTimerState();
  }
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = StepTween(
      begin: widget.duration.inSeconds,
      end: 0,
    ).animate(_controller);
    _animation.addListener(() {
      setState(() {

      });
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget child) {
        return widget.builder(context, Duration(seconds: _animation.value));
      },
    );
  }
}
