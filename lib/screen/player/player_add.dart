import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:multicricket/model/Player.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PlayerAdd extends StatefulWidget {
  final PlayerModel playerModel;

  PlayerAdd({Key? key, required this.playerModel}) : super(key: key); // Modify this line

  @override
  _PlayerAddState createState() => _PlayerAddState();
}

class _PlayerAddState extends State<PlayerAdd> {
  final _formKey = GlobalKey<FormState>();
  final _player = Player(name: 'null');
  String? _imagePath;
  String? _imageUrl;
  bool _uploading = false;
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
      _player.image64encode = _imageUrl;
      await FirebaseStorage.instance
          .ref(_imageUrl)
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
        title: Text('Add Player'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
          Container(
          width: 100, // Set the width
          height: 100,
            child:
            CircleAvatar(
              backgroundImage: _imagePath != null
                  ? FileImage(File(_imagePath!))
                  : AssetImage('images/player_default.png'),
              radius: 20,
            ),
            ),


            ElevatedButton(
              onPressed: takePicture,

              child: _uploading ? CircularProgressIndicator(): Icon(Icons.cloud_upload_rounded),
            ),
            Container(
              width: 200, // Set the width
              height: 60, // Set the height
            ),
            Container(
            width: 200, // Set the width
            height: 80, // Set the height
            child:
            TextFormField(
              decoration: InputDecoration(labelText: '*Player Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter player name';
                }
                return null;
              },
              onSaved: (value) {
                _player.name = value!;
              },
            ),
            ),

              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) {
                  _player.description = value!;
                },
              ),
            Container(
                width: 200, // Set the width
                height: 100, // Set the height
            ),

            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.playerModel.addPlayer(_player);
                  Navigator.pop(context);
                }
              },
              child: Icon(Icons.check)
            ),
          ],
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