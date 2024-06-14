import 'package:flutter/material.dart';
import 'package:multicricket/screen/player/player_add.dart';
import 'package:multicricket/screen/player/player_detail.dart';
import '../../model/Player.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
class PlayerList extends StatelessWidget {
  const PlayerList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Consumer<PlayerModel>(
        builder: (context, playerModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text('Player List'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (playerModel.loading) const CircularProgressIndicator() else
                  Expanded(
                    child: ListView.builder(
                    itemBuilder: (_, index) {
                      var player = playerModel.players[index];
                      var image = player.image64encode;
                      print(player.image64encode);
                      return ListTile(
                        leading: image != null
                          ? FutureBuilder<String>(
                              future: FirebaseStorage.instance.ref(image).getDownloadURL(),
                              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                if (!snapshot.hasData) {
                                  return CircularProgressIndicator();
                                }
                                var downloadURL = snapshot.data!;
                                print('players'+ downloadURL);
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
                                player: playerModel.players[index],
                                playerModel: playerModel
                              ),
                            ),
                          );
                        },
                      );
                    },
                    itemCount: playerModel.players.length
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