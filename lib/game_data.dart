class GameData {
  final int id;
  final String title;
  final int pcMetascore;
  final int x360Metascore;
  final int ps3Metascore;
  final int iosMetascore;

  GameData({this.id, this.title, this.pcMetascore, this.x360Metascore, this.ps3Metascore, this.iosMetascore});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'pcMetascore': pcMetascore,
      'x360Metascore': x360Metascore,
      'ps3Metascore': ps3Metascore,
      'iosMetascore': iosMetascore,
    };
  }
}
