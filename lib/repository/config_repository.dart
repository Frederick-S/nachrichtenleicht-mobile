import 'package:nachrichtenleicht/model/config.dart';
import 'package:sembast/sembast.dart';

import 'base_repository.dart';

class ConfigRepository extends BaseRepository {
  final _configStore = intMapStoreFactory.store('config');

  Future<List<Config>> getConfigs(int newsType) async {
    final database = await getDatabase();
    final finder = Finder(filter: Filter.equals('newsType', newsType));
    final snapshots = await _configStore.find(database, finder: finder);

    return snapshots.map((snapshot) {
      return Config.fromJson(snapshot.value);
    }).toList();
  }

  Future<Config> getConfig(int newsType) async {
    final configs = await getConfigs(newsType);

    return (configs != null && configs.length > 0) ? configs.first : null;
  }

  Future<void> save(Config config) async {
    final database = await getDatabase();

    await _configStore.record(config.id).put(database, config.toMap());
  }
}
