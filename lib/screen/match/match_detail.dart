import 'package:flutter/material.dart';
import 'package:multicricket/model/Match.dart';
import 'package:multicricket/model/Team.dart';
import 'package:multicricket/screen/match/team_selection_screen.dart';
import 'package:provider/provider.dart';

class MatchDetail extends StatefulWidget {
  final Match match ;
  final MatchModel matchModel;
  MatchDetail({required this.match,required this.matchModel});

  @override
  _MatchDetailState createState() => _MatchDetailState();
}

class _MatchDetailState extends State<MatchDetail> {
  final _formKey = GlobalKey<FormState>();
  late Team batterTeam;
  late Team bowlerTeam;

  @override
  Widget build(BuildContext context) {
    var teamModel = Provider.of<TeamModel>(context);
    batterTeam = teamModel.get(widget.match.batterTeamId) ?? Team(teamName: 'Select a team');
    bowlerTeam = teamModel.get(widget.match.bowlerTeamId) ?? Team(teamName: 'Select a team');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.match.title),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
          const SizedBox(
          height: 80,
          ),
            SizedBox(
              height: 80,
              width: 180,
              child: TextFormField(
                decoration: InputDecoration(labelText: '* Title'),
                initialValue: widget.match.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter match title';
                  }
                  return null;
                },
                onSaved: (value) {
                  widget.match.title = value!;
                },
              ),
            ),
            SizedBox(
              height: 80,
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                initialValue: widget.match.description,
                onSaved: (value) {
                  widget.match.description = value!;
                },
              ),
            ),
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_cricket, size: 30, color: Colors.redAccent),
                  Text('   ${batterTeam.teamName}', style: const TextStyle(fontSize: 18), ),
                  IconButton(
                    icon: Icon(Icons.chevron_right,size: 30,),
                    onPressed: () async {
                      var selectedTeam = await Navigator.push<Team>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamSelectionScreen(
                            selectedTeam: batterTeam,
                          ),
                        ),
                      );
                      if (selectedTeam != null) {
                        setState(() {
                          batterTeam = selectedTeam;
                          widget.match.batterTeamId = selectedTeam.id;
                          widget.match.batterTeamName = selectedTeam.teamName;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_baseball, size: 25, color: Colors.lightBlue),
                  Text('   ${bowlerTeam.teamName}', style: TextStyle(fontSize: 18)),
                  IconButton(
                    icon: Icon(Icons.chevron_right,size: 30,),
                    onPressed: () async {
                      var selectedTeam = await Navigator.push<Team>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamSelectionScreen(
                            selectedTeam: bowlerTeam,
                          ),
                        ),
                      );
                      if (selectedTeam != null) {
                        setState(() {
                          bowlerTeam = selectedTeam;
                          widget.match.bowlerTeamId = selectedTeam.id;
                          widget.match.bowlerTeamName = selectedTeam.teamName;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),


            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    child: Text('Delete'),
                    onPressed: () async {
                      await widget.matchModel.deleteMatch(widget.match);
                      Navigator.pop(context);
                    },
                  ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {

                    if (batterTeam.id  == bowlerTeam.id) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Batter team and bowler team could not be same.'))
                      );
                      return;
                    }

                    _formKey.currentState!.save();
                    await widget.matchModel.updateMatch(widget.match);
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              ),
      ]
            )



          ],
        ),
      ),
    );
  }
}