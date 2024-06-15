import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multicricket/model/History.dart';

import 'history_detail.dart';

class HistoryList extends StatefulWidget {
  const HistoryList({Key? key}) : super(key: key);

  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryModel>(
      builder: (context, historyModel, child) {
        var histories = historyModel.histories;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Histories'),
          ),
          body: ListView.builder(
            itemCount: histories.length,
            itemBuilder: (context, index) {
              var history = histories[index];
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(history.matchTitle, style: const TextStyle(fontSize: 22)),
                        IconButton(
                          icon: Icon(Icons.chevron_right, size: 30),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HistoryDetail(history: history),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${history.batterTeam}  VS  ${history.bowlerTeam}', style: TextStyle(fontSize: 16, color: Colors.black54)),
                        SizedBox(height: 30, child: Divider(color: Colors.black12, thickness: 1.5)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}