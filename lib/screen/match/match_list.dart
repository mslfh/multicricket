import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multicricket/model/Match.dart';
import 'package:multicricket/screen/match/match_score.dart';

import '../../model/History.dart';
import '../../model/Player.dart';
import '../../model/Team.dart';
import 'match_add.dart';
import 'match_detail.dart';

class MatchList extends StatefulWidget {
  const MatchList({Key? key}) : super(key: key);

  @override
  _MatchListState createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MatchModel>(
      builder: (context, matchModel, child) {
        var matches = matchModel.matches;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Matches'),
          ),
          body: ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              var match = matches[index];
              return Padding(padding: const EdgeInsets.all(10),
              child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:[
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Text(match.title, style: const TextStyle(fontSize: 22) ),
                    IconButton(
                      icon: Icon(Icons.chevron_right,size: 30,),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchDetail(
                                match: match,
                                matchModel: matchModel
                            ),
                          ),
                        );
                      },

                    )]
                    ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${match.batterTeamName}  VS  ${match.bowlerTeamName}', style:TextStyle(fontSize: 16, color: Colors.black54,) ),
                          SizedBox(
                            height: 30,
                            child:
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MatchScore(
                                  match: match,matchModel: matchModel,
                                  teamModel: Provider.of<TeamModel>(context, listen: false),
                                  playerModel: Provider.of<PlayerModel>(context, listen: false),
                                  historyModel: Provider.of<HistoryModel>(context, listen: false),
                                  ),
                                  ),
                                );
                              },
                              child: Text('Score Now'),
                            ),
                          )
                        ],
                      ),
                      SizedBox( height: 30, child: Divider( color: Colors.black12, thickness: 1.5,)),
                  ]

              ),);

            },
          ),

          floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchAdd(
                  matchModel: matchModel,
                  teamModel: Provider.of<TeamModel>(context, listen: false),
                ),
              ),
            );
          },
          child: const Icon(Icons.add),
            backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        );
      },
    );
  }
}