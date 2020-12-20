class Config {
  int id;

  int newsType;

  String newsFetchedStartUtc;

  String newsFetchedEndUtc;

  Config(
      {this.id,
      this.newsType,
      this.newsFetchedStartUtc,
      this.newsFetchedEndUtc});

  factory Config.fromJson(Map<String, dynamic> json) {
    final config = Config();
    config.id = json['id'];
    config.newsType = json['newsType'];
    config.newsFetchedStartUtc = json['newsFetchedStartUtc'];
    config.newsFetchedEndUtc = json['newsFetchedEndUtc'];

    return config;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'newsType': newsType,
      'newsFetchedStartUtc': newsFetchedStartUtc,
      'newsFetchedEndUtc': newsFetchedEndUtc
    };
  }
}
