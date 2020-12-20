import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nachrichtenleicht/model/news.dart';

class NewsService {
  Future<List<News>> fetchNewsList(
      DateTime startDate, DateTime endDate, int newsType) async {
    final response = await http.get(
        'https://nachrichtenleicht.dekiru.app/news?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}&type=$newsType');

    if (response.statusCode == 200) {
      final decoder = Utf8Decoder();
      final newsList = List.of(json.decode(decoder.convert(response.bodyBytes)))
          .map((news) => News.fromJson(news))
          .toList();

      newsList.sort((a, b) => -a.publishedAtUtc.compareTo(b.publishedAtUtc));

      return newsList;
    } else {
      throw Exception('Failed to fetch news');
    }
  }
}
