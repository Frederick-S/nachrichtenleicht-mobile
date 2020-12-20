import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewsList extends StatefulWidget {
  final int newsType;

  const NewsList(this.newsType);

  @override
  State<StatefulWidget> createState() {
    return NewsListState();
  }
}

class NewsListState extends State<NewsList> {
  int _newsType;

  @override
  void initState() {
    super.initState();

    _newsType = widget.newsType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(_newsType.toString()),
    );
  }
}
