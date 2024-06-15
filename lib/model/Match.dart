import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Match {
  late String id;
  String batterTeamId;
  String batterTeamName;
  String bowlerTeamId;
  String bowlerTeamName;
  String? description;
  String title;

  Match({
    required this.batterTeamId,
    required this.batterTeamName,
    required this.bowlerTeamId,
    required this.bowlerTeamName,
    this.description,
    required this.title,
  });

  factory Match.fromJson(Map<String, dynamic> json, String id) {
    return Match(
      batterTeamId: json['batterTeamId'],
      batterTeamName: json['batterTeamName'],
      bowlerTeamId: json['bowlerTeamId'],
      bowlerTeamName: json['bowlerTeamName'],
      description: json['description'],
      title: json['title'],
    )..id = id;
  }

  Map<String, dynamic> toJson() {
    return {
      'batterTeamId': batterTeamId,
      'batterTeamName': batterTeamName,
      'bowlerTeamId': bowlerTeamId,
      'bowlerTeamName': bowlerTeamName,
      'description': description,
      'title': title,
    };
  }
}

class MatchModel extends ChangeNotifier {
  final List<Match> matches = [];

  Match? get(String? id) {
    if (id == null) return null;
    return matches.firstWhere((match) => match.id == id);
  }

  CollectionReference matchesCollection = FirebaseFirestore.instance.collection('matches');
  bool loading = false;

  MatchModel() {
    fetch();
  }

  Future fetch() async {
    matches.clear();

    loading = true;
    notifyListeners();

    var querySnapshot = await matchesCollection.orderBy("title").get();

    for (var doc in querySnapshot.docs) {
      var match = Match.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      matches.add(match);
    }
    loading = false;
    notifyListeners();
  }

  Future addMatch(Match match) async {
    loading = true;
    notifyListeners();

    var docRef = await matchesCollection.add(match.toJson());
    match.id = docRef.id;
    matches.add(match);

    loading = false;
    notifyListeners();
  }

  Future updateMatch(Match match) async {
    loading = true;
    notifyListeners();

    await matchesCollection.doc(match.id).update(match.toJson());
    var index = matches.indexWhere((m) => m.id == match.id);
    matches[index] = match;

    loading = false;
    notifyListeners();
  }

  Future deleteMatch(Match match) async {

    loading = true;
    notifyListeners();

    await matchesCollection.doc(match.id).delete();
    matches.removeWhere((m) => m.id == match.id);

    loading = false;
    notifyListeners();
  }
}