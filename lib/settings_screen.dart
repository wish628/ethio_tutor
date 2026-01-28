import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _voiceFeedbackEnabled = true;
  double _speechSpeed = 1.0;
  String _selectedAccent = "standard";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _voiceFeedbackEnabled = prefs.getBool('voiceFeedback') ?? true;
      _speechSpeed = prefs.getDouble('speechSpeed') ?? 1.0;
      _selectedAccent = prefs.getString('accent') ?? "standard";
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voiceFeedback', _voiceFeedbackEnabled);
    await prefs.setDouble('speechSpeed', _speechSpeed);
    await prefs.setString('accent', _selectedAccent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Voice Feedback',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Enable Voice Response'),
                    value: _voiceFeedbackEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _voiceFeedbackEnabled = value;
                      });
                      _saveSettings();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Speech Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Speech Speed'),
                    subtitle: Slider(
                      value: _speechSpeed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 3,
                      label: '${_speechSpeed.toStringAsFixed(1)}x',
                      onChanged: (double value) {
                        setState(() {
                          _speechSpeed = value;
                        });
                        _saveSettings();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Learning Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Coming soon: Lesson plans, vocabulary lists, and progress tracking.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}