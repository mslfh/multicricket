import 'package:flutter/material.dart';
import '../../model/Player.dart';
import 'package:provider/provider.dart';

class PlayerDetails extends StatefulWidget {
  final Player player;
  final PlayerModel playerModel;

  PlayerDetails({Key? key, required this.player, required this.playerModel}) : super(key: key);

  @override
  _PlayerDetailsState createState() => _PlayerDetailsState();
}

class _PlayerDetailsState extends State<PlayerDetails> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController image64encodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.player.name;
    descriptionController.text = widget.player.description!;
    image64encodeController.text = widget.player.image64encode!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: image64encodeController,
              decoration: InputDecoration(labelText: 'Image'),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () async {
                widget.player.name = nameController.text;
                widget.player.description = descriptionController.text;
                widget.player.image64encode = image64encodeController.text;
                // Update the player in the PlayerModel
                await widget.playerModel.updatePlayer(widget.player);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}