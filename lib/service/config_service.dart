import 'package:nachrichtenleicht/model/config.dart';
import 'package:nachrichtenleicht/repository/config_repository.dart';

import '../error_reporter.dart';

class ConfigService {
  final _configRepository = ConfigRepository();

  Future<Config> getConfig(int newsType) async {
    try {
      return await _configRepository.getConfig(newsType);
    } catch (error, stackTrace) {
      ErrorReporter.reportError(error, stackTrace);
    }

    return null;
  }
}
