import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerList extends StatelessWidget {
  final List<Player> players;

  PlayerList(this.players);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: players.isEmpty
          ? Column(
              children: <Widget>[
                SizedBox(height: 20),
                Text('No players added yet!'),
              ],
            )
          : ListView.builder(
              itemCount: players.length,
              itemBuilder: (ctx, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: FittedBox(
                          child: Text('${players[index].setsPlayed} sets'),
                        ),
                      ),
                    ),
                    title: Text(
                      players[index].name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    subtitle: Text('Sets played: ${players[index].setsPlayed}'),
                  ),
                );
              },
            ),
    );
  }
}
