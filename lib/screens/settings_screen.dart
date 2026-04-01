import 'package:flutter/material.dart';
import 'package:hotelmind/widgets/developer_drawer.dart';
import 'package:hotelmind/models/UserPreferenceRoomMode.dart'; // UserPreferenceRoomMode importu eklendi

import '../services/debug_log_provider.dart';
import '../services/room_automation_service.dart';

class SettingsScreen extends StatefulWidget {
  final String roomId;
  final String sessionId;

  const SettingsScreen({super.key, required this.roomId, required this.sessionId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final RoomAutomationService _roomService = RoomAutomationService();
  late final String _roomId;

  // Settings
  double _preferredTemperature = 22.0;
  double _preferredHumidity = 50.0;
  bool _autoClimate = true;
  bool _automaticLights = true;
  bool _voiceReports = true;
  String _roomMode = 'comfort'; // comfort, eco, away
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _roomId = widget.roomId;
    _loadPreferences();
  }

  void _showDeveloperConsole() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeveloperConsoleSheet(),
    );
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final preferences = await _roomService.getUserPreferences(_roomId);

      setState(() {
        if (preferences != null) {
          log("Preferences loaded: $preferences");

          _preferredTemperature = preferences['preferredTemperature'] ?? 22.0;
          _preferredHumidity = preferences['preferredHumidity'] ?? 50.0;
          _autoClimate = preferences['autoClimate'] ?? true;
          _automaticLights = preferences['automaticLights'] ?? true;
          _voiceReports = preferences['voiceReports'] ?? true;

          final dynamic roomModeValue = preferences['roomMode'];
          if (roomModeValue is UserPreferenceRoomMode) {
            _roomMode = roomModeValue.toString().split('.').last;
          } else if (roomModeValue is String) {
            _roomMode = roomModeValue;
          } else {
            // If roomModeValue is null or an unexpected type, default value is used.
            _roomMode = 'comfort';
          }
        } else {
          // If preferences are null (service returned null), default values are set.
          _preferredTemperature = 22.0;
          _preferredHumidity = 50.0;
          _autoClimate = true;
          _automaticLights = true;
          _voiceReports = true;
          _roomMode = 'comfort';
          log("User preferences not found, using defaults.");
        }
        _isLoading = false;
      });
    } catch (e) {
      log("Error loading preferences: $e");
      setState(() {
        // In case of error, default values and loading state are set.
        _preferredTemperature = 22.0;
        _preferredHumidity = 50.0;
        _autoClimate = true;
        _automaticLights = true;
        _voiceReports = true;
        _roomMode = 'comfort';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error loading preferences"))
        );
      }
    }
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final preferences = {
        'preferredTemperature': _preferredTemperature,
        'preferredHumidity': _preferredHumidity,
        'autoClimate': _autoClimate,
        'automaticLights': _automaticLights,
        'voiceReports': _voiceReports,
        'roomMode': _roomMode
      };

      final success = await _roomService.saveUserPreferences(_roomId, preferences);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? "Settings saved successfully"
                  : "Error saving settings"
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            )
        );
      }
    } catch (e) {
      log("Error saving preferences: $e");
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error saving settings"),
              backgroundColor: Colors.red,
            )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: CircleAvatar(
          radius: 6,
          backgroundColor: Colors.grey.shade800.withValues(alpha: 0.7),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title and description area
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          textAlign: TextAlign.center,
                          'Personal Room Preferences',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 4,
                          color: Colors.blue,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Personalize your room settings to maximize your comfort',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Comfort Settings card
                  _buildSettingsCard(
                    title: 'Comfort Settings',
                    icon: Icons.thermostat,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Preferred temperature
                        Row(
                          children: [
                            const Icon(Icons.thermostat_outlined, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Preferred Temperature: ${_preferredTemperature.toStringAsFixed(1)}°C',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Slider(
                                    value: _preferredTemperature,
                                    min: 18,
                                    max: 28,
                                    divisions: 20,
                                    label: '${_preferredTemperature.toStringAsFixed(1)}°C',
                                    activeColor: Colors.orange,
                                    onChanged: (value) {
                                      setState(() {
                                        _preferredTemperature = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Preferred humidity
                        Row(
                          children: [
                            const Icon(Icons.water_drop_outlined, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Preferred Humidity: ${_preferredHumidity.toStringAsFixed(0)}%',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Slider(
                                    value: _preferredHumidity,
                                    min: 30,
                                    max: 70,
                                    divisions: 40,
                                    label: '${_preferredHumidity.toStringAsFixed(0)}%',
                                    activeColor: Colors.blue,
                                    onChanged: (value) {
                                      setState(() {
                                        _preferredHumidity = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Room Mode card
                  _buildSettingsCard(
                    title: 'Room Mode',
                    icon: Icons.home,
                    content: Column(
                      children: [
                        // Room mode selection
                        _buildModeOption(
                          title: 'Comfort Mode',
                          subtitle: 'Provides the most comfortable environment, higher energy consumption',
                          icon: Icons.weekend,
                          iconColor: Colors.purple,
                          value: 'comfort',
                          groupValue: _roomMode,
                        ),
                        const Divider(),
                        _buildModeOption(
                          title: 'Economy Mode',
                          subtitle: 'Saves energy, slightly reduced comfort',
                          icon: Icons.eco,
                          iconColor: Colors.green,
                          value: 'eco',
                          groupValue: _roomMode,
                        ),
                        const Divider(),
                        _buildModeOption(
                          title: 'Away Mode',
                          subtitle: 'Maximum energy saving, minimum active systems',
                          icon: Icons.directions_walk,
                          iconColor: Colors.orange,
                          value: 'away',
                          groupValue: _roomMode,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // General Settings card
                  _buildSettingsCard(
                    title: 'General Settings',
                    icon: Icons.settings,
                    content: Column(
                      children: [
                        // Auto climate
                        _buildSwitchOption(
                          title: 'Auto Climate',
                          subtitle: 'Automatically adjusts room temperature',
                          icon: Icons.ac_unit,
                          iconColor: Colors.lightBlue,
                          value: _autoClimate,
                          onChanged: (value) => setState(() => _autoClimate = value),
                        ),
                        const Divider(),

                        // Auto lighting
                        _buildSwitchOption(
                          title: 'Automatic Lighting',
                          subtitle: 'Automatically controls room lights',
                          icon: Icons.lightbulb_outline,
                          iconColor: Colors.amber,
                          value: _automaticLights,
                          onChanged: (value) => setState(() => _automaticLights = value),
                        ),
                        const Divider(),

                        // Voice reports
                        _buildSwitchOption(
                          title: 'Voice Reports',
                          subtitle: 'Provides status summary upon entering room',
                          icon: Icons.volume_up,
                          iconColor: Colors.green,
                          value: _voiceReports,
                          onChanged: (value) => setState(() => _voiceReports = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _savePreferences,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Settings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      // Developer console trigger button
      bottomNavigationBar: Container(
        height: 40,
        color: Colors.grey[200],
        child: InkWell(
          onTap: _showDeveloperConsole,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.code, size: 16),
              const SizedBox(width: 8),
              Text(
                'Developer Console',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create settings card
  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              width: 40,
              height: 3,
              color: Colors.blue.shade200,
            ),
            const SizedBox(height: 20),
            content,
          ],
        ),
      ),
    );
  }

  // Mode selection widget
  Widget _buildModeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String groupValue,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _roomMode = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              activeColor: Colors.blue,
              onChanged: (val) {
                setState(() {
                  _roomMode = val!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Switch selection widget
  Widget _buildSwitchOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.blue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}