import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';

void main() {
  runApp(StartupView());
}

class StartupView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeView(title: 'Multiple Audio Playback'),
    );
  }
}

class HomeView extends StatefulWidget {
  HomeView({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _HomeViewState createState() => _HomeViewState();
}

enum ChangeDirection { Up, Down }

class _HomeViewState extends State<HomeView> {
  AudioPlayer _player1;
  AudioPlayer _player2;
  bool _isInitialized = false;

  _HomeViewState() {
    initialize();
  }

  Future initialize() async {
    _player1 = AudioPlayer();
    _player2 = AudioPlayer();
    await _player1
        .setAsset("assets/audio/and-your-love-the-lemming-shepherds.mp3");
    await _player2.setAsset("assets/audio/forever-the-lemming-shepherds.mp3");
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> resetVolumeAndPlay(AudioPlayer target) async {
    target.play();
    await target.setVolume(0.0);
    return progressiveVolume(target, 1 / 60, ChangeDirection.Up, 1.0, 16);
  }

  void _playTrack1() {
    resetVolumeAndPlay(_player1);
  }

  void _playTrack2() {
    resetVolumeAndPlay(_player2);
  }

  void _fadeOutTrack1() {
    progressiveVolume(_player1, 1 / 60, ChangeDirection.Down, 0.0, 16)
        .then((value) => _player1.pause());
  }

  void _fadeOutTrack2() {
    progressiveVolume(_player2, 1 / 60, ChangeDirection.Down, 0.0, 16)
        .then((value) => _player2.pause());
  }

  Future progressiveVolume(AudioPlayer target, double increment,
      ChangeDirection direction, double goal, int delay) {
    return Future.delayed(Duration(milliseconds: delay)).then((value) async {
      var updatedVolume = (direction == ChangeDirection.Up
          ? min(goal, target.volume + increment)
          : max(goal, target.volume - increment));
      await target.setVolume(updatedVolume);
      var goalReached = direction == ChangeDirection.Down
          ? target.volume <= goal
          : target.volume >= goal;
      if (!goalReached) {
        await progressiveVolume(target, increment, direction, goal, delay);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _isInitialized ? 'Audio files loaded!' : 'Loading audio files...',
            ),
          ],
        ),
      ),
      persistentFooterButtons: <Widget>[
        IconButton(
          icon: Icon(Icons.play_circle_filled),
          tooltip: 'Play track 1',
          onPressed: _playTrack1,
        ),
        IconButton(
          icon: Icon(Icons.pause_circle_filled),
          tooltip: 'Fade track 1 out',
          onPressed: _fadeOutTrack1,
        ),
        IconButton(
          icon: Icon(Icons.play_circle_filled),
          tooltip: 'Play track 2',
          onPressed: _playTrack2,
        ),
        IconButton(
          icon: Icon(Icons.pause_circle_filled),
          tooltip: 'Fade track 2 out',
          onPressed: _fadeOutTrack2,
        ),
      ],
    );
  }
}
