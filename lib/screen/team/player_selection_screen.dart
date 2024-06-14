import 'package:flutter/material.dart';
import 'package:multicricket/model/Player.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PlayerSelectionScreen extends StatefulWidget {
  final List<Player> selectedPlayers;
  final List<Player> availablePlayers;

  PlayerSelectionScreen({Key? key, this.selectedPlayers = const [], this.availablePlayers = const []}) : super(key: key);

  @override
  _PlayerSelectionScreenState createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  List<Player> _selectedPlayers = [];
  List<Player> availablePlayers = [];

  @override
  void initState() {
    super.initState();
    _selectedPlayers = List.from(widget.selectedPlayers);
    availablePlayers = List.from(widget.availablePlayers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Players'),
      ),
      body: Consumer<PlayerModel>(
        builder: (context, playerModel, child) {
          return ListView.builder(
            itemCount: availablePlayers.length,
            itemBuilder: (context, index) {
              var player = availablePlayers[index];
              return CheckboxListTile(
                title: Text(player.name),
                secondary: player.image64encode != null
                    ? FutureBuilder<String>(
                        future: FirebaseStorage.instance
                            .ref(player.image64encode)
                            .getDownloadURL(),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          }
                          var downloadURL = snapshot.data!;
                          return CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(downloadURL));
                        },
                      )
                    : const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('images/player_default.png')),
                value: _selectedPlayers.contains(player),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedPlayers.add(player);
                    } else {
                      _selectedPlayers.remove(player);
                    }
                  });
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, _selectedPlayers);
        },
        child: Icon(Icons.check),
      ),
    );
  }
}