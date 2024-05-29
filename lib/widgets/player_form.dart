import 'package:flutter/material.dart';

class PlayerForm extends StatefulWidget {
  final Function onAddPlayer;

  PlayerForm({required this.onAddPlayer});

  @override
  _PlayerFormState createState() => _PlayerFormState();
}

class _PlayerFormState extends State<PlayerForm> {
  final _nameController = TextEditingController();
  final _setsPlayedController = TextEditingController();

  void _submitData() {
    final enteredName = _nameController.text;
    final enteredSets = int.parse(_setsPlayedController.text);

    if (enteredName.isEmpty || enteredSets <= 0) {
      return;
    }

    widget.onAddPlayer(enteredName, enteredSets);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
              controller: _nameController,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Sets Played'),
              controller: _setsPlayedController,
              keyboardType: TextInputType.number,
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
