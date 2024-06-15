import 'package:flutter/foundation.dart';

import 'Player.dart';

class ScoreView extends ChangeNotifier {
  int wicketsLost = 0;
  int oversCompleted = 0;
  int ballsDelivered = 0;
  int totalRuns = 0;
  double runsRate = 0.0;
  int playerLeft = 5;
  String title = "";
  String batterTeamName = "";
  String bowlerTeamName = "";

  Player currentBatter = Player(name: '');
  Player nextBatter = Player(name: '');
  int batterRuns = 0;
  int batterBalls = 0;
  int nonStrikerRuns = 0;
  int nonStrikerBalls = 0;
  int batterExtra = 0;
  Player bowler = Player(name: '');
  int bowlerBalls = 0;
  int bowlerWickets = 0;
  int bowlerLost = 0;
  int countBoundaries = 0;

  ScoreView() {
    reset();
  }

  void reset() {
    countBoundaries = 0;
    oversCompleted = 0;
    ballsDelivered = 0;
    playerLeft = 5;
    runsRate = 0.0;
    wicketsLost = 0;
    totalRuns = 0;
    nonStrikerRuns = 0;
    nonStrikerBalls = 0;
    batterExtra = 0;
    batterRuns = 0;
    batterBalls = 0;
    bowlerBalls = 0;
    bowlerWickets = 0;
    bowlerLost = 0;
    notifyListeners();
  }

  void dotBall() {
    oneBall();
    updateRunsRate();
  }

  void oneBall() {
    bowlerBalls++;
    ballsDelivered++;
    batterBalls++;
    nonStrikerBalls++;
    if (ballsDelivered % 6 == 0) {
      oversCompleted++;
      ballsDelivered = 0;
    }
    notifyListeners();
  }

  void addScore(int value) {
    oneBall();
    totalRuns += value;
    bowlerLost += value;
    batterRuns += value;
    if (value == 2 || value == 4 || value == 6) {
      nonStrikerRuns++;
    }
    if (value == 4 || value == 6) {
      countBoundaries++;
    }
    updateRunsRate();
  }

  void out() {
    oneBall();
    wicketsLost++;
    bowlerWickets++;
    updateRunsRate();
  }

  void noBallOrWide() {
    totalRuns++;
    batterExtra++;
    updateRunsRate();
  }

  void updateRunsRate() {
    int balls = oversCompleted * 6 + ballsDelivered;
    double overs = balls / 6.0;
    if (overs != 0.0) {
      runsRate = totalRuns / overs;
    }
    notifyListeners();
  }
}