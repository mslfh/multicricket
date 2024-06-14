import 'package:flutter/material.dart';
import 'package:multicricket/screen/team/team_add.dart';
import 'package:multicricket/screen/team/team_detail.dart';
import '../../model/Player.dart';
import '../../model/Team.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TeamList extends StatelessWidget {
  const TeamList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamModel>(
        builder: (context, teamModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text('Team List'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (teamModel.loading) const CircularProgressIndicator() else
                  Expanded(
                    child: ListView.builder(
                    itemBuilder: (_, index) {
                      var team = teamModel.teams[index];

                      var image = team.image64encode;
                      return ListTile(
                        leading: image != null
                            ? FutureBuilder<String>(
                          future: FirebaseStorage.instance.ref(image).getDownloadURL(),
                          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            var downloadURL = snapshot.data!;
                            print('teams'+ downloadURL);
                            return CircleAvatar(radius: 20, backgroundImage: NetworkImage(downloadURL));
                          },
                        )
                            : const CircleAvatar(radius: 20, backgroundImage: AssetImage('images/team_default.png')),
                        title: Text(team.teamName),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeamDetails(
                                team: teamModel.teams[index],
                                teamModel: teamModel,
                                playerModel: Provider.of<PlayerModel>(context, listen: false),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    itemCount: teamModel.teams.length
                  )
                  )
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamAdd(
                    teamModel: teamModel,
                    playerModel: Provider.of<PlayerModel>(context, listen: false),
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