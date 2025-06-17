import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onUnitChanged;
  final bool initialIsCelsius;

  const SettingsScreen({
    super.key,
    required this.onUnitChanged,
    required this.initialIsCelsius,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isCelsius;
  final _storage = const FlutterSecureStorage();
  final _tempUnitKey = 'temperature_unit';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isCelsius = widget.initialIsCelsius;
  }

  Future<void> _toggleTemperatureUnit(bool value) async {
    setState(() => _isLoading = true);
    try {
      await _storage.write(
        key: _tempUnitKey,
        value: value ? 'celsius' : 'fahrenheit',
      );
      setState(() => _isCelsius = value);
      widget.onUnitChanged(value);
    } catch (e) {
      debugPrint('Error saving temperature unit: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Temperature Unit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<bool>(
                    title: const Text('Celsius (°C)'),
                    value: true,
                    groupValue: _isCelsius,
                    onChanged: (value) => _toggleTemperatureUnit(true),
                  ),
                  RadioListTile<bool>(
                    title: const Text('Fahrenheit (°F)'),
                    value: false,
                    groupValue: _isCelsius,
                    onChanged: (value) => _toggleTemperatureUnit(false),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isCelsius ? 'Using Celsius (°C)' : 'Using Fahrenheit (°F)',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}