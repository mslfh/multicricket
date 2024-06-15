import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Ball {
  String overs;
  String type ;
  String currentBowler;
  String currentBatter;
  Ball({required this.overs, required this.type, required this.currentBowler, required this.currentBatter});

  Map<String, dynamic> toJson() {
    return {
      'overs': overs,
      'type': type,
      'currentBowler': currentBowler,
      'currentBatter': currentBatter,
    };
  }
}

class History {
  late String id;
  String batterTeam;
  String bowlerTeam;
  String matchTitle;
  String finalScore;
  List<Ball> balls ;

  History({
    required this.batterTeam,required this.bowlerTeam,required this.matchTitle,required this.finalScore,required this.balls
  });

  factory History.fromJson(Map<String, dynamic> json, String id) {
    return History(
      batterTeam: json['batterTeam'],
      bowlerTeam: json['bowlerTeam'],
      matchTitle: json['matchTitle'],
      finalScore: json['finalScore'],
      balls: json['balls']
    )..id = id;
  }

  Map<String, dynamic> toJson() {
    return {
      'batterTeam': batterTeam,
      'bowlerTeam': bowlerTeam,
      'matchTitle': matchTitle,
      'finalScore': finalScore,
      'balls': balls.map((ball) => ball.toJson()).toList(),
    };
  }
}

class HistoryModel extends ChangeNotifier {
  final List<History> histories = [];

  History? get(String? id) {
    if (id == null) return null;
    return histories.firstWhere((history) => history.id == id);
  }

  CollectionReference historiesCollection = FirebaseFirestore.instance.collection('histories');
  bool loading = false;

  HistoryModel() {
    fetch();
  }

  Future fetch() async {
    histories.clear();

    loading = true;
    notifyListeners();

    var querySnapshot = await historiesCollection.orderBy("title").get();

    for (var doc in querySnapshot.docs) {
      var history = History.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      histories.add(history);
    }
    loading = false;
    notifyListeners();
  }

  Future addMatch(History history) async {
    loading = true;
    notifyListeners();

    var docRef = await historiesCollection.add(history.toJson());
    history.id = docRef.id;
    histories.add(history);

    loading = false;
    notifyListeners();
  }

}