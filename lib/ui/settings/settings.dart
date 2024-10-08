import 'package:app_music/Provider/provider.dart';
import 'package:app_music/ui/now_playing/audio_player_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';

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
  late AudioPlayerManager _audioPlayerManager;
  int? _selectedTimer; // Biến lưu trữ thời gian hẹn giờ
  Timer? _sleepTimer; // Timer cho chức năng hẹn giờ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
        child: Consumer<UiProvider>(
          builder: (context, notifier, child) {
            return Column(
              children: [
                // Dark Mode
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: notifier.isDark,
                    onChanged: (value) => notifier.changeTheme(),
                  ),
                ),
                // Sleep Timer
                ListTile(
                  title: const Text('Sleep Timer'),
                  trailing: DropdownButton<int>(
                    value: _selectedTimer,
                    hint: const Text('Select Time'),
                    items: [15, 30, 45, 60] // Các lựa chọn thời gian hẹn giờ (phút)
                        .map((time) {
                      return DropdownMenuItem<int>(
                        value: time,
                        child: Text('$time minutes'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTimer = value;
                        // Bắt đầu timer
                        _startSleepTimer(value);
                      });
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _startSleepTimer(int? duration) {
    // Hủy timer cũ nếu có
    _sleepTimer?.cancel();

    // Khởi tạo timer mới
    if (duration != null) {
      _sleepTimer = Timer(Duration(minutes: duration), () {
        SystemNavigator.pop();
        // Tắt âm thanh hoặc thực hiện hành động khi hết thời gian
        // Ở đây bạn có thể gọi hàm tắt âm thanh
        print('Sleep Timer ended.'); // Thay thế với hành động thực tế
        setState(() {
          _selectedTimer = null; // Reset lựa chọn hẹn giờ
        });
      });
    }
  }

  @override
  void dispose() {
    // Hủy timer khi widget bị hủy
    _sleepTimer?.cancel();
    super.dispose();
  }
}
