import 'package:flutter/material.dart';
import 'package:multicricket/screen/team/team_add.dart';
import 'package:multicricket/screen/team/team_detail.dart';
import '../../model/Player.dart';
import '../../model/Team.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TeamList extends StatefulWidget {
  const TeamList({Key? key}) : super(key: key);

  @override
  _TeamListState createState() => _TeamListState();
}
class _TeamListState extends State<TeamList> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamModel>(
      builder: (context, teamModel, child) {
        var teams = teamModel.teams;
        if (_searchController.text.isNotEmpty) {
          teams = teams.where((team) => team.teamName.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: _isSearching
                ? TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search',
              ),
              onChanged: (value) {
                setState(() {
                });
              },
            )
                : const Text('Teams'),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                    }
                  });
                },
              ),
            ],
          ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (teamModel.loading) const CircularProgressIndicator() else
                  Expanded(
                    child: ListView.builder(
                    itemBuilder: (_, index) {
                      var team = teams[index];
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
                                team: teams[index],
                                teamModel: teamModel,
                                playerModel: Provider.of<PlayerModel>(context, listen: false),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    itemCount: teams.length
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

class FullScreenText extends StatelessWidget {
  final String text;

  const FullScreenText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection:TextDirection.ltr, child: Column(children: [ Expanded(child: Center(child: Text(text))) ]));
  }
}