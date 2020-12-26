import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nachrichtenleicht/model/news.dart';

class NewsDetail extends StatefulWidget {
  final News news;

  const NewsDetail(this.news);

  @override
  State<StatefulWidget> createState() {
    return NewsDetailState();
  }
}

class NewsDetailState extends State<NewsDetail> {
  News _news;

  @override
  void initState() {
    super.initState();

    this._news = widget.news;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Nachrichtenleicht'),
          ),
        ),
        onWillPop: null);
  }
}
