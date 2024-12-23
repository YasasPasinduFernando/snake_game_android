import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/score.dart';

class HighScoresScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('High Scores'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<Score>>(
        future: DatabaseHelper.instance.getTopScores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No scores yet!'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final score = snapshot.data![index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text('${index + 1}'),
                  ),
                  title: Text('Score: ${score.score}'),
                  subtitle: Text('Date: ${score.date}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await DatabaseHelper.instance.deleteScore(score.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Score deleted')),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}