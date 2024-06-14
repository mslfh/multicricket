import 'package:flutter/material.dart';
import 'package:multicricket/screen/player/player_detail.dart';
import '../../model/Player.dart';
import 'package:provider/provider.dart';

class PlayerList extends StatelessWidget {
  const PlayerList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlayerModel(),
      child: Consumer<PlayerModel>(
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
                          return ListTile(
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
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
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