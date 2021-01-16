import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nachrichtenleicht/model/news.dart';

import '../error_reporter.dart';

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
  bool _isPlaying = false;
  AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();

    this._news = widget.news;
    _audioPlayer = AudioPlayer();

    if (_hasAudio()) {
      _audioPlayer.setUrl(_news.audioUrl).catchError((error, stackTrace) {
        ErrorReporter.reportError(error, stackTrace);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Nachrichtenleicht'),
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Stack(
              children: <Widget>[_buildNewsBody()],
            ),
          ),
          floatingActionButton: _hasAudio() ? _buildAudioPlayer() : Container(),
        ),
        onWillPop: () async {
          if (_hasAudio()) {
            try {
              await _audioPlayer.dispose();
            } catch (error, stackTrace) {
              ErrorReporter.reportError(error, stackTrace);
            }
          }

          return true;
        });
  }

  Widget _buildNewsBody() {
    return InAppWebView(
      initialUrl: Uri.dataFromString(_buildNewsHtml(_news),
              mimeType: 'text/html', encoding: utf8)
          .toString(),
      onConsoleMessage: (InAppWebViewController inAppWebViewController,
          ConsoleMessage consoleMessage) {
        print(consoleMessage.message);

        if (consoleMessage.messageLevel == ConsoleMessageLevel.ERROR) {
          ErrorReporter.reportError(consoleMessage.message, null);
        }
      },
    );
  }

  _buildNewsHtml(News news) {
    final image = news.imageUrl != '' ? '<img src=${news.imageUrl} />' : '';

    return """
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body>
          <style>
            * {
              font-size: 16px;
            }
            h1 {
              font-size: 20px;
            }
            img {
              max-width: 100%;
            }
            .description {
              font-weight: bold;
            }
          </style>
          <h1>${news.title}</h1>
          <p class="description">${news.description}</p>
          $image
          ${news.body}
        </body>
      </html>
    """;
  }

  bool _hasAudio() {
    return _news.audioUrl != null && _news.audioUrl != '';
  }

  Widget _buildAudioPlayer() {
    return FloatingActionButton(
        onPressed: () async {
          if (_audioPlayer.playbackState == AudioPlaybackState.stopped ||
              _audioPlayer.playbackState == AudioPlaybackState.paused) {
            _audioPlayer.play().catchError((error, stackTrace) {
              ErrorReporter.reportError(error, stackTrace);
            });
          } else if (_audioPlayer.playbackState == AudioPlaybackState.playing) {
            _audioPlayer.pause().catchError((error, stackTrace) {
              ErrorReporter.reportError(error, stackTrace);
            });
          }

          setState(() {
            _isPlaying =
                _audioPlayer.playbackState == AudioPlaybackState.playing;
          });
        },
        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow));
  }
}
