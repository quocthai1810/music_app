import 'package:app_music/Provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        body: Container(
          alignment: Alignment.topCenter, padding: EdgeInsets.only(top: 90),
          child: Consumer(
              builder: (context, UiProvider notifier, child) {
                return Column(
                    children:[ ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: Switch(value: notifier.isDark, onChanged: (value)=>notifier.changeTheme(),
                )
                ,)
                ]
                );
              }
          ),
        ));
  }
}
