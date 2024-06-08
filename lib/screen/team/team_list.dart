

import 'package:flutter/material.dart';

class TeamList extends StatefulWidget {
  const TeamList({Key? key}) : super(key: key);

  @override
  _TeamListState createState() => _TeamListState();
}
class _TeamListState extends State<TeamList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Team List'),
      ),
      body: const Center(
        child: Text('Team List'),
      ),
    );
  }
}