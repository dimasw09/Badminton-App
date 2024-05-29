import 'package:flutter/material.dart';

class PlayerForm extends StatefulWidget {
  final Function onAddPlayer;

  PlayerForm({required this.onAddPlayer});

  @override
  _PlayerFormState createState() => _PlayerFormState();
}

class _PlayerFormState extends State<PlayerForm> {
  final _nameController = TextEditingController();
  int _setsPlayed = 0;

  void _submitData() {
    final enteredName = _nameController.text;

    if (enteredName.isEmpty) {
      return;
    }

    widget.onAddPlayer(
      enteredName,
      _setsPlayed,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
              controller: _nameController,
              onSubmitted: (_) => _submitData(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Sets Played: $_setsPlayed'),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (_setsPlayed > 0) _setsPlayed--;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _setsPlayed++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              child: Text('Add Player'),
              onPressed: _submitData,
            ),
          ],
        ),
      ),
    );
  }
}
