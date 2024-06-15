import 'package:flutter/material.dart';
import 'package:multicricket/model/History.dart';

class HistoryDetail extends StatelessWidget {
  final History history;

  HistoryDetail({required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(history.matchTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Batter Team: ${history.batterTeam}', style: TextStyle(fontSize: 20)),
            Text('Bowler Team: ${history.bowlerTeam}', style: TextStyle(fontSize: 20)),
            Text('Final Score: ${history.finalScore}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Text('Balls:', style: TextStyle(fontSize: 20)),
            Expanded(
              child: ListView.builder(
                itemCount: history.balls.length,
                itemBuilder: (context, index) {
                  var ball = history.balls[index];
                  return ListTile(
                    title: Text('Over: ${ball.overs}'),
                    subtitle: Text('Type: ${ball.type}\nBowler: ${ball.currentBowler}\nBatter: ${ball.currentBatter}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}