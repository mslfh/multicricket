import 'package:flutter/material.dart';

class PlayerList extends StatefulWidget {
  const PlayerList({Key? key}) : super(key: key);

  @override
  _PlayerListState createState() => _PlayerListState();
}
class _PlayerListState extends State<PlayerList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Player List'),
      ),
      body: const Center(
        child: Text('Player List'),
      ),
    );
  }
}