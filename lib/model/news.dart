class News {
  int id;

  String title;

  String description;

  String url;

  String imageUrl;

  String body;

  String audioUrl;

  String publishedAtUtc;

  int publishedAtEpoch;

  int type;

  News();

  factory News.fromJson(Map<String, dynamic> json) {
    final news = News();
    news.id = json['id'];
    news.title = json['title'];
    news.description = json['description'];
    news.url = json['url'];
    news.imageUrl = json['imageUrl'];
    news.body = json['body'];
    news.audioUrl = json['audioUrl'];
    news.publishedAtUtc = json['publishedAtUtc'];
    news.publishedAtEpoch =
        DateTime.parse(news.publishedAtUtc).millisecondsSinceEpoch;
    news.type = json['type'];

    return news;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'imageUrl': imageUrl,
      'body': body,
      'audioUrl': audioUrl,
      'publishedAtUtc': publishedAtUtc,
      'publishedAtEpoch': publishedAtEpoch,
      'type': type
    };
  }
}
