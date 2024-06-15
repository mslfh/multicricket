
import 'package:flutter/material.dart';
import 'package:multicricket/model/Match.dart';
import 'package:multicricket/model/Player.dart';
import 'package:multicricket/model/ScoreView.dart';
import 'package:multicricket/model/Team.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../model/History.dart';

class MatchScore extends StatefulWidget {
  final Match match;
  final MatchModel matchModel;
  final TeamModel teamModel;
  final PlayerModel playerModel;
  final HistoryModel historyModel;
  MatchScore({required this.match,required this.matchModel,required this.teamModel,
    required this.playerModel,required this.historyModel});
  @override
  _MatchScoreState createState() => _MatchScoreState();
}

class _MatchScoreState extends State<MatchScore> {
  late ScoreView scoreView;

  late History history;

  bool showBatterSelection = true;

  List<Player> batterPlayers = [];
  List<Player> bowlerPlayers = [];

  @override
  void initState() {
    super.initState();
    scoreView = ScoreView();

    history = History(batterTeam: widget.match.batterTeamName, bowlerTeam: widget.match.bowlerTeamName,
        matchTitle: widget.match.title, finalScore: '', balls: []);

    var batterTeam = widget.teamModel.get(widget.match.batterTeamId);
    var bowlerTeam = widget.teamModel.get(widget.match.bowlerTeamId);

    batterPlayers = batterTeam != null ? batterTeam.playerIds!.map((id) => widget.playerModel.getPlayer(id)).toList().cast<Player>() : [];
    bowlerPlayers = bowlerTeam != null ? bowlerTeam.playerIds!.map((id) => widget.playerModel.getPlayer(id)).toList().cast<Player>() : [];

    scoreView.currentBatter  = batterPlayers[0];
    batterPlayers.removeAt(0);
    scoreView.nextBatter = batterPlayers[0];
    batterPlayers.removeAt(0);
    scoreView.bowler = bowlerPlayers[0];
  }

  void selectBatter(BuildContext context) async {
  final Player? selectedPlayer = await showDialog<Player>(
    context: context,
    builder: (BuildContext context) {
      return
        WillPopScope(
          onWillPop: () async => false,
      child:
        SimpleDialog(
        title: const Text('Select Batter'),
        children: batterPlayers.map((Player player) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, player);
            },
            child: Row(
              children: [
                player.image64encode != null
                    ? FutureBuilder<String>(
                  future: FirebaseStorage.instance.ref(player.image64encode ).getDownloadURL(),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    var downloadURL = snapshot.data!;
                    return CircleAvatar(radius: 20, backgroundImage: NetworkImage(downloadURL));
                  },
                )
                    : const CircleAvatar(radius: 20, backgroundImage: AssetImage('images/player_default.png')),
                SizedBox(width: 10), // Add some spacing between the image and the text
                Text(player.name),
              ],
            ),
          );
        }).toList(),
      ),
      );
    },
  );

  if (selectedPlayer != null) {
    setState(() {
      batterPlayers.remove(selectedPlayer);
      scoreView.currentBatter = selectedPlayer;
      showBatterSelection = false;
    });
  }
}

  void selectBowler(BuildContext context) async {
  final Player? selectedPlayer = await showDialog<Player>(
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
          onWillPop: () async => false,
      child:SimpleDialog(
        title: const Text('Select Bowler'),
        children: bowlerPlayers.where((player) => player != scoreView.bowler).map((Player player) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, player);
            },
            child: Row(
              children: [
                player.image64encode != null
                    ? FutureBuilder<String>(
                  future: FirebaseStorage.instance.ref(player.image64encode ).getDownloadURL(),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    var downloadURL = snapshot.data!;
                    return CircleAvatar(radius: 20, backgroundImage: NetworkImage(downloadURL));
                  },
                )
                    : const CircleAvatar(radius: 20, backgroundImage: AssetImage('images/player_default.png')),
                SizedBox(width: 10), // Add some spacing between the image and the text
                Text(player.name),
              ],
            ),
          );
        }).toList(),
      )
      )
      ;
    },
  );

  if (selectedPlayer != null) {
    setState(() {
      scoreView.bowler = selectedPlayer;
      showBatterSelection = false;
    });
  }
  }

  void showGameOverDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SimpleDialog(
          title: Text('Game Over', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple)),
          children: <Widget>[
            SimpleDialogOption(
              child: Text('Returning to match list.',style: TextStyle( color: Colors.black45)),
            ),
          ],
        );
      },
    );
  }

  void checkGameOverAndNavigate(BuildContext context) async {
    if ((scoreView.oversCompleted == 5 && scoreView.ballsDelivered == 5) || batterPlayers.isEmpty) {
       showGameOverDialog(context);
      await Future.delayed(const Duration(seconds: 1)); // wait for 2 seconds before navigating

      // save history
      history.finalScore = '${scoreView.totalRuns}/${scoreView.wicketsLost}';

      print(history.balls.length);
      print(history.finalScore);
      await widget.historyModel.addMatch(history);

      await widget.matchModel.deleteMatch(widget.match);

       Navigator.pop(context);
       Navigator.pop(context);
    }
  }

  void recordBall(type) {
    Ball ball = Ball(
        overs: '${scoreView.oversCompleted}.${scoreView.ballsDelivered}',
        type: type,
        currentBowler: scoreView.bowler.name,
        currentBatter: scoreView.currentBatter.name
    );
    history.balls.add(ball);
    showBatterSelection = true;
  }

  @override
  Widget build(BuildContext context) {

    // check over
    WidgetsBinding.instance!.addPostFrameCallback((_) => checkGameOverAndNavigate(context));
    if (scoreView.ballsDelivered != 0 && scoreView.ballsDelivered % 5 == 0
        && showBatterSelection ) {
      showBatterSelection = false;
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        selectBowler(context);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Scoring'),
      ),
      body: Column(
        children: [
          Text('Batter Team: ${widget.match.batterTeamName}'),
          Text('Bowler Team: ${widget.match.bowlerTeamName}'),
          Text('Score: ${scoreView.totalRuns}'),
          Text('Wickets Lost: ${scoreView.wicketsLost}'),
          Text('Overs Completed: ${scoreView.oversCompleted}'),
          Text('Balls Delivered: ${scoreView.ballsDelivered}'),
          Text('Current Batter: ${scoreView.currentBatter.name}'),
          Text('Next Batter: ${scoreView.nextBatter.name}'),
          Text('Current Bowler: ${scoreView.bowler.name}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(
              width: 120,
            ),
            ElevatedButton(
            onPressed: () {
              setState(() {
                selectBatter(context);
                scoreView.out();
                recordBall('Out');
              });
            },
            child: Text('Out'),
          )]
        ),
      const SizedBox(
        height: 120,
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 120,
                child:  ElevatedButton(
                  onPressed: () {
                    setState(() {
                      scoreView.dotBall();
                      recordBall('Dot Ball');
                    });
                  },
                  child: Text('Dot Ball'),
                ),
                ),
              SizedBox(
                width: 120,
                child:  ElevatedButton(
                  onPressed: () {
                    setState(() {
                      scoreView.addScore(1);
                      recordBall('+1 runs');
                    });
                  },
                  child: Text('+1'),
                ),
              ),
              SizedBox(
                width: 120,
                child:  ElevatedButton(
                  onPressed: () {
                    setState(() {
                      scoreView.addScore(2);
                      recordBall('+2 runs');
                    });
                  },
                  child: Text('+2'),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 120,
                child:  ElevatedButton(
                  onPressed: () {
                    setState(() {
                      scoreView.addScore(3);
                      recordBall('+3 runs');
                    });
                  },
                  child: Text('+3'),
                ),
              ),
              SizedBox(
                width: 120,
                child:  ElevatedButton(
                  onPressed: () {
                    setState(() {
                      scoreView.addScore(4);
                      recordBall('Boundary +4 runs');
                    });
                  },
                  child: Text('Boundary +4'),
                ),
              ),
              SizedBox(
                width: 120,
                child:  ElevatedButton(
                  onPressed: () {
                    setState(() {
                      scoreView.addScore(5);
                      recordBall('+5 runs');
                    });
                  },
                  child: Text('+5'),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 120,
                child:  ElevatedButton(
                  onPressed: () {
                    setState(() {
                      scoreView.addScore(6);
                      recordBall('Boundary +6 runs');
                    });
                  },
                  child: Text('Boundary +6'),
                ),
              ),
              SizedBox(
                width: 120,
                child:  ElevatedButton(
                  onPressed: () {
                    setState(() {
                      scoreView.noBallOrWide();
                      recordBall('No Ball');
                    });
                  },
                  child: Text('No Ball'),
                ),
              ),
              SizedBox(
                width: 120,
                child:  ElevatedButton(
                  onPressed: () {
                    setState(() {

                      scoreView.noBallOrWide();
                      recordBall('No Ball');
                    });
                  },
                  child: Text('Wide'),
                ),
              ),
            ],
          ),
        ],
      ),],
      ),
    );
  }
}