import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nachrichtenleicht/model/news.dart';
import 'package:nachrichtenleicht/service/cached_news_service.dart';
import 'package:nachrichtenleicht/service/config_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../error_reporter.dart';
import 'news_detail.dart';

class NewsList extends StatefulWidget {
  final int newsType;

  const NewsList(this.newsType);

  @override
  State<StatefulWidget> createState() {
    return NewsListState();
  }
}

class NewsListState extends State<NewsList>
    with AutomaticKeepAliveClientMixin<NewsList> {
  int _newsType;
  final _configService = ConfigService();
  final _cachedNewsService = CachedNewsService();
  final _newsList = List<News>();
  final _refreshController = RefreshController(initialRefresh: true);
  final _newsFetchIntervalDays = 14;

  @override
  void initState() {
    super.initState();

    _newsType = widget.newsType;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        onRefresh: _refreshNewsList,
        onLoading: _loadNewsList,
        child: ListView.separated(
            itemBuilder: (item, i) {
              return _buildNews(_newsList[i]);
            },
            separatorBuilder: (context, i) => Divider(
                  color: Colors.grey,
                ),
            itemCount: _newsList.length),
      ),
    );
  }

  Widget _buildNews(News news) {
    return ListTile(
      title: Text(news.title),
      subtitle: Text(DateTime.parse(news.publishedAtUtc).toLocal().toString()),
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(news.imageUrl),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) {
          return NewsDetail(news);
        }));
      },
    );
  }

  _refreshNewsList() async {
    final config = await _configService.getConfig(_newsType);
    final latestNews = _newsList.isEmpty ? null : _newsList.first;
    final useConfigDate = config != null && latestNews == null;
    DateTime newestDate = latestNews == null
        ? (config != null
                ? DateTime.parse(config.newsFetchedEndUtc)
                : DateTime.now().toUtc())
            .subtract(Duration(days: _newsFetchIntervalDays))
        : DateTime.parse(latestNews.publishedAtUtc).add(new Duration(days: 1));
    DateTime startDate = DateTime.utc(
        newestDate.year, newestDate.month, newestDate.day, 0, 0, 0);
    DateTime endDate = useConfigDate
        ? DateTime.parse(config.newsFetchedEndUtc)
        : DateTime.utc(
                newestDate.year, newestDate.month, newestDate.day, 23, 59, 59)
            .add(Duration(days: _newsFetchIntervalDays));

    _cachedNewsService
        .fetchNewsList(startDate, endDate, _newsType)
        .then((List<News> newsList) {
      if (newsList.isNotEmpty) {
        setState(() {
          _newsList.insertAll(0, newsList);
        });
      }

      _refreshController.refreshCompleted();
    }).catchError((error, stackTrace) {
      ErrorReporter.reportError(error, stackTrace);

      Fluttertoast.showToast(
          msg: 'Network error', gravity: ToastGravity.CENTER);

      _refreshController.refreshFailed();
    });
  }

  _loadNewsList() {
    final lastNews = _newsList.isEmpty ? null : _newsList.last;
    DateTime oldestDate = lastNews == null
        ? DateTime.now().toUtc()
        : DateTime.parse(lastNews.publishedAtUtc)
            .subtract(new Duration(days: 1));
    DateTime startDate =
        DateTime.utc(oldestDate.year, oldestDate.month, oldestDate.day, 0, 0, 0)
            .subtract(new Duration(days: _newsFetchIntervalDays));
    DateTime endDate = DateTime.utc(
        oldestDate.year, oldestDate.month, oldestDate.day, 23, 59, 59);

    _cachedNewsService
        .fetchNewsList(startDate, endDate, _newsType)
        .then((List<News> newsList) {
      if (newsList.isNotEmpty) {
        setState(() {
          _newsList.addAll(newsList);
        });

        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    }).catchError((error, stackTrace) {
      ErrorReporter.reportError(error, stackTrace);

      Fluttertoast.showToast(
          msg: 'Network error', gravity: ToastGravity.CENTER);

      _refreshController.loadFailed();
    });
  }

  @override
  bool get wantKeepAlive => true;
}
