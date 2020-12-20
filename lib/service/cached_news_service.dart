import 'package:nachrichtenleicht/model/config.dart';
import 'package:nachrichtenleicht/model/news.dart';
import 'package:nachrichtenleicht/repository/config_repository.dart';
import 'package:nachrichtenleicht/repository/news_repository.dart';

import '../error_reporter.dart';
import 'config_service.dart';
import 'news_service.dart';

class CachedNewsService {
  final _configRepository = ConfigRepository();
  final _newsRepository = NewsRepository();
  final _configService = ConfigService();
  final _newsService = NewsService();

  Future<List<News>> fetchNewsList(
      DateTime startDate, DateTime endDate, int newsType) async {
    final config = await _configService.getConfig(newsType);

    if (config != null && (_newsCached(config, startDate, endDate))) {
      try {
        final news =
            await _newsRepository.getNews(startDate, endDate, newsType);

        news.sort((a, b) => -a.publishedAtUtc.compareTo(b.publishedAtUtc));

        return news;
      } catch (error, stackTrace) {
        ErrorReporter.reportError(error, stackTrace);

        return _newsService.fetchNewsList(startDate, endDate, newsType);
      }
    } else {
      final news =
          await _newsService.fetchNewsList(startDate, endDate, newsType);

      if (news == null || news.length == 0) {
        return [];
      }

      final newsFetchedStartUtc = news.last.publishedAtUtc;
      final newsFetchedEndUtc = news.first.publishedAtUtc;
      final newConfig = _createNewConfig(
          config, newsFetchedStartUtc, newsFetchedEndUtc, newsType);

      try {
        _newsRepository.saveAll(news);
        _configRepository.save(newConfig);
      } catch (error, stackTrace) {
        ErrorReporter.reportError(error, stackTrace);
      }

      return news;
    }
  }

  bool _newsCached(Config config, DateTime startDate, DateTime endDate) {
    final newsFetchedStartDate = DateTime.parse(config.newsFetchedStartUtc);
    final newsFetchedEndDate = DateTime.parse(config.newsFetchedEndUtc);

    return newsFetchedStartDate.compareTo(startDate) <= 0 &&
        newsFetchedEndDate.compareTo(endDate) >= 0;
  }

  Config _createNewConfig(Config config, String newsFetchedStartUtc,
      String newsFetchedEndUtc, int newsType) {
    if (config != null) {
      final newsFetchedStartUtcNew = DateTime.parse(newsFetchedStartUtc)
                  .compareTo(DateTime.parse(config.newsFetchedStartUtc)) <=
              0
          ? newsFetchedStartUtc
          : config.newsFetchedStartUtc;
      final newsFetchedEndUtcNew = DateTime.parse(newsFetchedEndUtc)
                  .compareTo(DateTime.parse(config.newsFetchedEndUtc)) >=
              0
          ? newsFetchedEndUtc
          : config.newsFetchedEndUtc;

      return Config(
          id: config.id,
          newsType: newsType,
          newsFetchedStartUtc: newsFetchedStartUtcNew,
          newsFetchedEndUtc: newsFetchedEndUtcNew);
    } else {
      return Config(
          id: newsType,
          newsType: newsType,
          newsFetchedStartUtc: newsFetchedStartUtc,
          newsFetchedEndUtc: newsFetchedEndUtc);
    }
  }
}
