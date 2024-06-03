import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/player.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<Player> _players = [];
  final TextEditingController _rentalDurationController =
      TextEditingController();
  final TextEditingController _rentalCostController = TextEditingController();
  final TextEditingController _shuttlecockCostController =
      TextEditingController();

  int _rentalDurationHours = 2;
  int _rentalCostPerHour = 35000;
  int _shuttlecockCost = 51000;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late AnimationController _fadeInAnimationController;

  @override
  void initState() {
    super.initState();
    _fadeInAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _addPlayer(String name, int setsPlayed) {
    final newPlayer = Player(name: name, setsPlayed: setsPlayed);
    setState(() {
      _players.add(newPlayer);
    });
    _showNotification(name);

    // Animasi fade in
    _fadeInAnimationController.forward();
  }

  void _editPlayer(Player player, int newSetsPlayed) {
    setState(() {
      player.setsPlayed = newSetsPlayed;
    });
  }

  void _deletePlayer(Player player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${player.name}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _players.remove(player);
              });
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _startAddNewPlayer(BuildContext ctx) {
    final TextEditingController _setsPlayedController = TextEditingController();
    int setsPlayed = 0;

    showDialog(
      context: ctx,
      builder: (_) {
        String playerName = '';
        return AlertDialog(
          title: Text('Add New Player'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Player Name'),
                onChanged: (value) {
                  playerName = value;
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sets Played'),
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      if (setsPlayed > 0) {
                        setState(() {
                          setsPlayed--;
                          _setsPlayedController.text = setsPlayed.toString();
                        });
                      }
                    },
                  ),
                  SizedBox(
                    width: 40,
                    child: TextField(
                      controller: _setsPlayedController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        setState(() {
                          setsPlayed = int.parse(value);
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        setsPlayed++;
                        _setsPlayedController.text = setsPlayed.toString();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add Player'),
              onPressed: () {
                if (playerName.isNotEmpty) {
                  _addPlayer(playerName, setsPlayed);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _startEditPlayer(BuildContext ctx, Player player) {
    int newSetsPlayed = player.setsPlayed;

    showDialog(
      context: ctx,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Sets Played'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (newSetsPlayed > 0) newSetsPlayed--;
                      });
                    },
                  ),
                  Text(newSetsPlayed.toString()),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        newSetsPlayed++;
                      });
                    },
                  ),
                ],
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
                    _editPlayer(player, newSetsPlayed);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showNotification(String playerName) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'your channel id', 'your channel name',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');

    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'New Player Added',
        '$playerName has been added to the game', platformChannelSpecifics,
        payload: 'item x');
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Costs updated successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Badminton Cost Splitter'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
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
            child: AnimatedBuilder(
              animation: _fadeInAnimationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeInAnimationController.value,
                  child: child,
                );
              },
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
                        child: ListView.builder(
                          itemCount: _players.length,
                          itemBuilder: (ctx, index) {
                            final player = _players[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: ListTile(
                                title: Text(player.name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    'Sets Played: ${player.setsPlayed}',
                                    style: TextStyle(color: Colors.grey)),
                                trailing: Text(
                                  'Rp ${_calculateCostPerPerson(player).toStringAsFixed(2)}',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                leading: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deletePlayer(player),
                                ),
                                onTap: () => _startEditPlayer(context, player),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
