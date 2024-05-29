import 'package:flutter/material.dart';
import '../models/player.dart';
import '../widgets/player_form.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Player> _players = [];
  final TextEditingController _rentalDurationController =
      TextEditingController();
  final TextEditingController _rentalCostController = TextEditingController();
  final TextEditingController _shuttlecockCostController =
      TextEditingController();

  int _rentalDurationHours = 2;
  int _rentalCostPerHour = 35000;
  int _shuttlecockCost = 51000;

  void _addPlayer(String name, int setsPlayed) {
    final newPlayer = Player(name: name, setsPlayed: setsPlayed);
    setState(() {
      _players.add(newPlayer);
    });
  }

  void _editPlayer(Player player, int newSetsPlayed) {
    setState(() {
      player.setsPlayed = newSetsPlayed;
    });
  }

  void _deletePlayer(Player player) {
    setState(() {
      _players.remove(player);
    });
  }

  void _startAddNewPlayer(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return PlayerForm(onAddPlayer: _addPlayer);
      },
    );
  }

  void _startEditPlayer(BuildContext ctx, Player player) {
    showDialog(
      context: ctx,
      builder: (context) {
        final _setsPlayedController =
            TextEditingController(text: player.setsPlayed.toString());

        return AlertDialog(
          title: Text('Edit Sets Played'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Sets Played'),
            controller: _setsPlayedController,
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                final newSetsPlayed = int.parse(_setsPlayedController.text);
                _editPlayer(player, newSetsPlayed);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  double _calculateCostPerPerson(Player player) {
    int totalSetsPlayed =
        _players.fold(0, (sum, player) => sum + player.setsPlayed);

    if (totalSetsPlayed == 0) return 0;

    double costPerSet =
        (_rentalCostPerHour * _rentalDurationHours) / totalSetsPlayed;
    double shuttlecockCostPerPerson = _shuttlecockCost / _players.length;

    return player.setsPlayed * costPerSet + shuttlecockCostPerPerson;
  }

  void _updateCosts() {
    setState(() {
      _rentalDurationHours = int.parse(_rentalDurationController.text);
      _rentalCostPerHour = int.parse(_rentalCostController.text);
      _shuttlecockCost = int.parse(_shuttlecockCostController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Badminton Cost Splitter'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _startAddNewPlayer(context),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Card(
            elevation: 5,
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    decoration:
                        InputDecoration(labelText: 'Rental Duration (hours)'),
                    controller: _rentalDurationController,
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _updateCosts(),
                  ),
                  TextField(
                    decoration:
                        InputDecoration(labelText: 'Rental Cost per Hour'),
                    controller: _rentalCostController,
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _updateCosts(),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Shuttlecock Cost'),
                    controller: _shuttlecockCostController,
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _updateCosts(),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    child: Text('Update Costs'),
                    onPressed: _updateCosts,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Card(
              elevation: 5,
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Player Costs',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        children: _players.map((player) {
                          return Card(
                            child: ListTile(
                              title: Text(player.name),
                              subtitle:
                                  Text('Sets Played: ${player.setsPlayed}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () =>
                                        _startEditPlayer(context, player),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _deletePlayer(player),
                                  ),
                                ],
                              ),
                              leading: Text(
                                'Rp ${_calculateCostPerPerson(player).toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewPlayer(context),
      ),
    );
  }
}
