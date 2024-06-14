import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  late String id;
  String name;
  String? description;
  String? image64encode;

  Player({required this.name, this.description, this.image64encode});

  factory Player.fromJson(Map<String, dynamic> json, String id) {
    return Player(
      name: json['name'],
      description: json['description'],
      image64encode: json['image64encode'],
    )..id = id;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image64encode': image64encode,
    };
  }
}

class PlayerModel extends ChangeNotifier {
  final List<Player> players = [];

  Player? get(String? id) {
    if (id == null) return null;
    return players.firstWhere((player) => player.id == id);
  }

  CollectionReference playersCollection = FirebaseFirestore.instance.collection('players');
  bool loading = false;

  PlayerModel() {
    fetch();
  }

  Future fetch() async {
    players.clear();

    loading = true;
    notifyListeners();

    var querySnapshot = await playersCollection.orderBy("name").get();

    for (var doc in querySnapshot.docs) {
      var player = Player.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      players.add(player);
    }
    loading = false;
    notifyListeners();
    print(loading);
  }

  Future addPlayer(Player player) async {
    loading = true;
    notifyListeners();

    var docRef = await playersCollection.add(player.toJson());
    player.id = docRef.id;
    players.add(player);

    loading = false;
    notifyListeners();

  }

  Future updatePlayer(Player player) async {
    loading = true;
    notifyListeners();

    await playersCollection.doc(player.id).update(player.toJson());
    var index = players.indexWhere((p) => p.id == player.id);
    players[index] = player;

    loading = false;
    notifyListeners();
  }

  Future deletePlayer(Player player) async {
    loading = true;
    notifyListeners();

    await playersCollection.doc(player.id).delete();
    players.removeWhere((p) => p.id == player.id);

    loading = false;
    notifyListeners();
  }
}