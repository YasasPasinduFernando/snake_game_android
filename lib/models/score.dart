class Score {
  final int? id;
  final int score;
  final String date;

  Score({
    this.id,
    required this.score,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'score': score,
      'date': date,
    };
  }

  static Score fromMap(Map<String, dynamic> map) {
    return Score(
      id: map['id'],
      score: map['score'],
      date: map['date'],
    );
  }
}