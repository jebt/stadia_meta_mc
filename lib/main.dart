import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'game_data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Future<Database> database;

  void _incrementCounter() {
    //_httpTest();
    _dbTest();
    setState(() {
      _counter++;
    });
  }

  void _dbTest() async {
    database = _openDb();
    List<GameData> games = await getGames();

    for (GameData gameData in games) {
      List<int> scores = [gameData.pcMetascore, gameData.x360Metascore, gameData.ps3Metascore, gameData.iosMetascore];
      int sum = 0;
      for (int score in scores) {
        sum += score;
      }
      int mean = (sum / scores.length).round();
      print('"${gameData.title}" gets an average score of $mean across different platforms.');
    }
  }

  void _httpTest() async {
    RegExp regExpScores = RegExp('(?<=<span class="metascore_w .+>)([1-9]{2})(?=<)');

    String platBefore = '<span class="platform">';
    String platAfter = '</span>';
    RegExp regExpPlats = RegExp('(?<=$platBefore)([0-9A-Za-z]+)(?=$platAfter)');

    http.Response response = await http
        .get('https://www.metacritic.com/search/all/lara%20croft%20and%20the%20guardian%20of%20light/results');
    Iterable<RegExpMatch> scoreMatches = regExpScores.allMatches(response.body);
    Iterable<RegExpMatch> platMatches = regExpPlats.allMatches(response.body);

    // for (RegExpMatch match in platMatches) {
    //   print(match[0]);
    // }
    //
    // for (RegExpMatch match in scoreMatches) {
    //   print(match[0]);
    // }

    List<RegExpMatch> platMatchesList = List.from(platMatches);
    List<RegExpMatch> scoreMatchesList = List.from(scoreMatches);

    int id = 1;
    String title = 'Lara Croft and the Guardian of Light';
    int pcMetascore;
    int x360Metascore;
    int ps3Metascore;
    int iosMetascore;

    for (int i = 0; i < scoreMatches.length; i++) {
      String plat = platMatchesList[i][0];
      int score = int.parse(scoreMatchesList[i][0]);
      if (plat == 'PC') {
        pcMetascore = score;
      } else if (plat == 'X360') {
        x360Metascore = score;
      } else if (plat == 'PS3') {
        ps3Metascore = score;
      } else if (plat == 'iOS') {
        iosMetascore = score;
      }

      print('${platMatchesList[i][0]}: ${scoreMatchesList[i][0]}');
    }

    GameData gameData = GameData(
      id: id,
      title: title,
      pcMetascore: pcMetascore,
      x360Metascore: x360Metascore,
      ps3Metascore: ps3Metascore,
      iosMetascore: iosMetascore,
    );

    //print(scoreMatches);
    //List<String> ratings =
    //log(response.body);

    //await insertGameData(gameData);
  }

  Future<List<GameData>> getGames() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('games');
    return List.generate(maps.length, (i) {
      return GameData(
        id: maps[i]['id'],
        title: maps[i]['title'],
        pcMetascore: maps[i]['pcMetascore'],
        x360Metascore: maps[i]['x360Metascore'],
        ps3Metascore: maps[i]['ps3Metascore'],
        iosMetascore: maps[i]['iosMetascore'],
      );
    });
  }

  Future<void> insertGameData(GameData gameData) async {
    final Database db = await database;
    await db.insert(
      'games',
      gameData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Database> _openDb() async {
    WidgetsFlutterBinding.ensureInitialized();
    final Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'games_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE games(id INTEGER PRIMARY KEY, title TEXT, pcMetascore INTEGER, x360Metascore INTEGER, ps3Metascore INTEGER, iosMetascore INTEGER)",
        );
      },
      version: 1,
    );
    return database;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
