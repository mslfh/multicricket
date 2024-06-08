
import 'package:flutter/material.dart';

class HistoryList extends StatefulWidget {
  const HistoryList({Key? key}) : super(key: key);

  @override
  _HistoryListState createState() => _HistoryListState();
}
class _HistoryListState extends State<HistoryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('History List'),
      ),
      body: const Center(
        child: Text('History List'),
      ),
    );
  }
}