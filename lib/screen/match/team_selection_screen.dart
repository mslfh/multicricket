import 'package:flutter/material.dart';
import 'package:multicricket/model/Team.dart';
import 'package:provider/provider.dart';

class TeamSelectionScreen extends StatefulWidget {
  final Team selectedTeam;

  TeamSelectionScreen({required this.selectedTeam});

  @override
  _TeamSelectionScreenState createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  late Team selectedTeam;

  @override
  void initState() {
    super.initState();
    selectedTeam = widget.selectedTeam;
  }

  @override
  Widget build(BuildContext context) {
    var teamModel = Provider.of<TeamModel>(context);
    var teams = teamModel.teams;

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Team'),
      ),
      body: ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          var team = teams[index];
          return ListTile(
            title: Text(team.teamName),
            trailing: Radio<Team>(
              value: team,
              groupValue: selectedTeam,
              onChanged: (Team? value) {
                setState(() {
                  selectedTeam = value!;
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, selectedTeam);
        },
        child: Icon(Icons.check),
      ),
    );
  }
}