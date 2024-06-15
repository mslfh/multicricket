import 'package:flutter/material.dart';
import 'package:multicricket/model/Team.dart';
import 'package:multicricket/screen/match/team_selection_screen.dart';
import '../../model/Match.dart';

class MatchAdd extends StatefulWidget {
  final MatchModel matchModel;
  final TeamModel teamModel;

  MatchAdd({required this.matchModel, required this.teamModel});

  @override
  _MatchAddState createState() => _MatchAddState();
}

class _MatchAddState extends State<MatchAdd> {
  final _formKey = GlobalKey<FormState>();
  late Team batterTeam;
  late Team bowlerTeam;
  final _match = Match(
    batterTeamId: '',
    batterTeamName: '',
    bowlerTeamId: '',
    bowlerTeamName: '',
    title: '',
  );
  @override
  void initState() {
    super.initState();
    batterTeam = Team(teamName: 'Select Batter team');
    bowlerTeam = Team(teamName: 'Select Bowler team');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Match'),
      ),
      body: Scaffold(
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
          child:
            TextFormField(
              decoration: InputDecoration(labelText: '* Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter match title';
                }
                return null;
              },
              onSaved: (value) {
                _match.title = value!;
              },
            ),
            ),
        SizedBox(
          height: 80,
          width: 300,
          child:
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              onSaved: (value) {
                _match.description = value!;
              },
            ),
            ),
            SizedBox(
              height: 60,
              child:
              Row(
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
                          _match.batterTeamId = selectedTeam.id;
                          _match.batterTeamName = selectedTeam.teamName;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),


            SizedBox(
              height: 80,
            child:
            Row(
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
                        _match.bowlerTeamId = selectedTeam.id;
                        _match.bowlerTeamName = selectedTeam.teamName;
                      });
                    }
                  },
                ),
              ],
            ),
            ),

            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (batterTeam.teamName == 'Select Batter team' || bowlerTeam.teamName == 'Select Bowler team') {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select batter team and bowler team.'))
                    );
                    return;
                  }

                  if (batterTeam.id  == bowlerTeam.id) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Batter team and bowler team could not be same.'))
                    );
                    return;
                  }

                  _formKey.currentState!.save();
                  await widget.matchModel.addMatch(_match);
                  Navigator.pop(context);
                }
              },
              child: Icon(Icons.check),
            ),

          ],
        ),
      ),
      ),
    );
  }
}