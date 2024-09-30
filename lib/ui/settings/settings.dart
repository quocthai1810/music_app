import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsTabPage();
  }
}

class SettingsTabPage extends StatefulWidget {
  const SettingsTabPage({super.key});

  @override
  State<SettingsTabPage> createState() => _SettingsTabPageState();
}

class _SettingsTabPageState extends State<SettingsTabPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(alignment: Alignment.topCenter,padding: EdgeInsets.only(top: 90),
          child: Column(
            children:[ ListTile(
                  leading: Icon(Icons.dark_mode),
              title: Text('Dark Mode'),
              trailing: Switch(value: true, onChanged: (value){}),
                ),
            ]
          ),
        ));
  }
}
