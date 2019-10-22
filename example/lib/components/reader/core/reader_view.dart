import 'package:example/components/reader/core/reader_settings.dart';
import 'package:flutter/cupertino.dart';

class ReaderView extends StatefulWidget {
  const ReaderView({
    Key key,
    this.settings = const ReaderSettings(),
  }) : super(key: key);

  final ReaderSettings settings;

  @override
  State<StatefulWidget> createState() {
    return _ReaderViewState();
  }
}

class _ReaderViewState extends State<ReaderView> {
  @override
  Widget build(BuildContext context) {
    return null;
  }
}
