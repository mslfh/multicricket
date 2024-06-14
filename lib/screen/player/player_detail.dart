import 'package:flutter/material.dart';
import '../../model/Player.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'player_add.dart';

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
  String? _imagePath;
  String? _imageUrl;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.player.name;
    descriptionController.text = widget.player.description!;
    _imageUrl = widget.player.image64encode;
  }

  Future<void> takePicture() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    var picture = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(
          camera: firstCamera,
        ),
      ),
    );
    setState(() {
      _imagePath = picture?.path;
      _uploading = true; // Set _uploading to true when the upload starts
    });
    //Upload the File
    try {
      _imageUrl = 'uploads/multicricket' + DateTime.now().millisecondsSinceEpoch.toString() + '.jpeg';
      widget.player.image64encode = _imageUrl;
      await FirebaseStorage.instance
          .ref(_imageUrl!)
          .putFile(File(_imagePath!));
    } on FirebaseException catch (e) {
      print('Error while uploading file: ${e.toString()}');
      _uploading = false;
      return;
    } catch (e) {
      print('Unexpected error: ${e.toString()}');
      _uploading = false;
      return;
    }

    setState(() {
      _uploading = false;
    });
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
            SizedBox(
              width: 100, // Set the width
              height: 100,
              child: _imageUrl != null
                  ? FutureBuilder<String>(
                future: FirebaseStorage.instance.ref(_imageUrl).getDownloadURL(),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  var downloadURL = snapshot.data!;
                  return CircleAvatar(radius: 20, backgroundImage: NetworkImage(downloadURL));
                },
              )
                  : const CircleAvatar(radius: 20, backgroundImage: AssetImage('images/player_default.png')),
            ),
            ElevatedButton(
              onPressed: takePicture,
              child: _uploading ? CircularProgressIndicator() : Icon(Icons.cloud_upload_rounded),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
        const SizedBox(
          height: 50,
        ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: Text('Delete'),
                    onPressed: () async {
                      await widget.playerModel.deletePlayer(widget.player);
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton(
                    child: Text('Save'),
                    onPressed: () async {
                      widget.player.name = nameController.text;
                      widget.player.description = descriptionController.text;
                      widget.player.image64encode = _imageUrl;
                      // Update the player in the PlayerModel
                      await widget.playerModel.updatePlayer(widget.player);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),

          ],
        ),
      ),
    );
  }
}