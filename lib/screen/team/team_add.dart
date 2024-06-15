import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:multicricket/model/Team.dart';
import 'package:multicricket/screen/team/player_selection_screen.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../model/Player.dart';

class TeamAdd extends StatefulWidget {
  final TeamModel teamModel;
  final PlayerModel playerModel;
  TeamAdd({Key? key, required this.teamModel, required this.playerModel}) : super(key: key); // Modify this line
  @override
  _TeamAddState createState() => _TeamAddState();
}

class _TeamAddState extends State<TeamAdd> {

  final _formKey = GlobalKey<FormState>();
  final _team = Team(teamName: 'null');
  String? _imagePath;
  String? _imageUrl;
  bool _uploading = false;
  List<Player> _selectedPlayers = [];

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
      _team.image64encode = _imageUrl;
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
    return
      Scaffold(
      appBar: AppBar(
        title: Text('Add Team'),
      ),
      body: SingleChildScrollView(
        child:
          Form(
          key: _formKey,
          child:Column(
          children: <Widget>[
            Container(
              width: 100, // Set the width
              height: 100,
              child: CircleAvatar(
                backgroundImage: _imagePath != null
                    ? FileImage(File(_imagePath!))
                    : AssetImage('images/team_default.png'),
                radius: 20,
              ),
            ),

            ElevatedButton(
              onPressed: takePicture,
              child: _uploading ? CircularProgressIndicator() : Icon(Icons.cloud_upload_rounded),
            ),
        SizedBox(
          width: 170, // Set the width
          child:
            TextFormField(
              decoration: InputDecoration(labelText: '*Team Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter team name';
                }
                return null;
              },
              onSaved: (value) {
                _team.teamName = value!;
              },
            ),
            ),
        SizedBox(
          height: 80,
          width: 370, // Set the width
          child:
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              onSaved: (value) {
                _team.description = value!;
              },
            ),
            ),

        Padding(padding: const EdgeInsets.all(20.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              const Text('Players', style: TextStyle(fontSize: 20)),
              ElevatedButton(
              onPressed: () async {
                // Get all the players
                var allPlayers = widget.playerModel.players;
                // Get all the playerIds from all the teams
                var allPlayerIdsInTeams = widget.teamModel.teams.expand((team) => team.playerIds!).toList();
                // Filter the players who are not in any team
                var availablePlayers = allPlayers.where((player) => !allPlayerIdsInTeams.contains(player.id)).toList();
                // Navigate to player selection screen and get the result
                final selectedPlayers = await Navigator.push<List<Player>>(
                  context,
                  MaterialPageRoute(builder: (context) => PlayerSelectionScreen(
                    selectedPlayers: _selectedPlayers,
                    availablePlayers: availablePlayers,
                  )),
                );
                if (selectedPlayers != null) {
                  setState(() {
                    _selectedPlayers = selectedPlayers;
                  });
                }
              },
              child: Icon(Icons.edit),
            ),
            ]
        ),),
        SizedBox(
          height: _selectedPlayers.length * 60 + 30,
          child:
            Expanded(
              child: ListView.builder(
                itemCount: _selectedPlayers.length,
                itemBuilder: (context, index) {
                  var player = _selectedPlayers[index];
                  return ListTile(
                    leading:  player.image64encode != null
                          ? FutureBuilder<String>(
                        future: FirebaseStorage.instance.ref(player.image64encode).getDownloadURL(),
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
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _selectedPlayers.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            ),

            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _team.playerIds = _selectedPlayers.map((player) => player.id).toList(); // Set playerIds
                  await  widget.teamModel.addTeam(_team);
                  Navigator.pop(context);
                }
              },
              child: Icon(Icons.check)
            ),
          ],
        ),
      ),
      ),
    );


  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            final picture = File(image!.path);
            Navigator.pop(context, picture);
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}