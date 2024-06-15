import 'package:flutter/material.dart';
import 'package:multicricket/screen/player/player_add.dart';
import 'package:multicricket/screen/player/player_detail.dart';
import '../../model/Player.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';


class PlayerList extends StatefulWidget {
  const PlayerList({Key? key}) : super(key: key);

  @override
  _PlayerListState createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerModel>(
      builder: (context, playerModel, child) {
        var players = playerModel.players;
        if (_searchController.text.isNotEmpty) {
          players = players.where((player) => player.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
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
                setState(() {});
              },
            )
                : const Text('Players'),
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
                if (playerModel.loading) const CircularProgressIndicator() else
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (_, index) {
                      var player = players[index];
                      var image = player.image64encode;
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
                          : const CircleAvatar(radius: 20, backgroundImage: AssetImage('images/player_default.png')),
                        title: Text(player.name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerDetails(
                                player: players[index],
                                playerModel: playerModel
                              ),
                            ),
                          );
                        },
                      );
                    },
                    itemCount: players.length
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
                  builder: (context) => PlayerAdd(
                    playerModel: playerModel,
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