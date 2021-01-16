import 'dart:async';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:nachrichtenleicht/widget/news_list.dart';
import 'package:nachrichtenleicht/widget/settings.dart';

import 'error_reporter.dart';
import 'news_type.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GlobalConfiguration().loadFromAsset('config');

  runZoned<Future<void>>(() async {
    runApp(Nachrichtenleicht());
  }, onError: (error, stackTrace) {
    _reportError(error, stackTrace);
  });

  FlutterError.onError = (details, {bool forceReport = false}) {
    if (isInDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
}

Future<void> _reportError(dynamic error, dynamic stackTrace) async {
  if (isInDebugMode) {
    print(stackTrace);
  } else {
    ErrorReporter.reportError(error, stackTrace);
  }
}

bool get isInDebugMode {
  bool inDebugMode = false;

  assert(inDebugMode = true);

  return inDebugMode;
}

class Nachrichtenleicht extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NewsTab(),
    );
  }
}

class NewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
            title: Text('Nachrichtenleicht'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  _openSettings(context);
                },
              )
            ],
            bottom: TabBar(
              tabs: [
                Tab(
                  text: "Nachrichten",
                ),
                Tab(
                  text: "Kultur",
                ),
                Tab(
                  text: "Vermischtes",
                ),
                Tab(
                  text: "Sport",
                ),
              ],
            )),
        body: TabBarView(
          children: [
            NewsList(NewsType.Nachrichten),
            NewsList(NewsType.Kultur),
            NewsList(NewsType.Vermischtes),
            NewsList(NewsType.Sport),
          ],
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Settings();
    }));
  }
}
