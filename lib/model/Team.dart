import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  late String id;
  String teamName;
  String? description;
  String? image64encode;
  List<String>? playerIds;

  Team({required this.teamName, this.description, this.image64encode, this.playerIds});

  factory Team.fromJson(Map<String, dynamic> json, String id) {
    return Team(
      teamName: json['teamName'],
      description: json['description'],
      image64encode: json['image64encode'],
      playerIds: json['playerIds'] != null ? List<String>.from(json['playerIds']) : [],
    )..id = id;
  }

  Map<String, dynamic> toJson() {
    return {
      'teamName': teamName,
      'description': description,
      'image64encode': image64encode,
      'playerIds': playerIds,
    };
  }
}

class TeamModel extends ChangeNotifier {
  final List<Team> teams = [];

  Team? get(String? id) {
    if (id == null) return null;
    return teams.firstWhere((team) => team.id == id);
  }

  CollectionReference teamsCollection = FirebaseFirestore.instance.collection('teams');
  bool loading = false;

  TeamModel() {
    fetch();
  }

  Future fetch() async {
    teams.clear();

    loading = true;
    notifyListeners();

    var querySnapshot = await teamsCollection.orderBy("teamName").get();

    for (var doc in querySnapshot.docs) {
      var team = Team.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      teams.add(team);
    }
    loading = false;
    notifyListeners();
  }

  Future addTeam(Team team) async {
    loading = true;
    notifyListeners();

    var docRef = await teamsCollection.add(team.toJson());
    team.id = docRef.id;
    teams.add(team);

    loading = false;
    notifyListeners();
  }

  Future updateTeam(Team team) async {
    loading = true;
    notifyListeners();

    await teamsCollection.doc(team.id).update(team.toJson());
    var index = teams.indexWhere((t) => t.id == team.id);
    teams[index] = team;

    loading = false;
    notifyListeners();
  }

  Future deleteTeam(Team team) async {
    loading = true;
    notifyListeners();

    await teamsCollection.doc(team.id).delete();
    teams.removeWhere((t) => t.id == team.id);

    loading = false;
    notifyListeners();
  }
}