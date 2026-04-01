import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmind/models/QrSession.dart';
import 'package:hotelmind/screens/settings_screen.dart';
import 'package:hotelmind/services/event_bus.dart';
import 'package:hotelmind/services/navigation_service.dart';

import '../services/debug_log_provider.dart';
import '../services/room_automation_service.dart';
import '../services/sensor_service.dart';
import '../widgets/event_list.dart';
import '../widgets/room_status_card.dart';
import '../widgets/sensor_chart.dart';

part 'dashboard_mixin.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String sessionId;

  const DashboardScreen({
    super.key,
    required this.roomId,
    required this.sessionId,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with _DashboardMixin, SingleTickerProviderStateMixin {

  // add to initState method in _DashboardScreenState
  @override
  void initState() {
    super.initState();

    // Call animation start method in Mixin and pass this (TickerProvider)
    initAIAnimation(this);
  }

  Future<void> _showSettingsDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          clipBehavior: Clip.antiAlias, // To crop content overflowing from corners
          insetPadding: EdgeInsets.all(16), // Distance from screen
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.75, // Width limitation
            child: SettingsScreen(roomId: _roomId, sessionId: _currentSessionId),
          ),
        );
      },
    );
  }

  Future<void> _showCleaningRequestDialog() async {
    String note = '';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cleaning Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Do you have any requests to pass on to the cleaning team?'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Extra towels, extra sheets, etc.',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                note = value;
              },
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                //await _roomService.sendCleaningRequest(_roomId, note);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Your cleaning request has been submitted'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('An error occurred while sending the request'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Send Request'),
          ),
        ],
      ),
    );
  }

  // NEW: Send message to reception
  Future<void> _showReceptionMessageDialog() async {
    String message = '';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message to Reception'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Type your message:'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type your message here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              onChanged: (value) {
                message = value;
              },
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (message.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please write a message'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              try {
                //await _roomService.sendMessageToReception(_roomId, message);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Your message has been sent to reception'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('An error occurred while sending the message'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  // Dialog for viewing active users
  Future<void> _showActiveUsersDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Active Sessions in the Room'),
        content: SizedBox(
          width: double.maxFinite, // Set dialog width
          height: 300, // Add height
          child: FutureBuilder<List<QrSession?>>(
            future: _getActiveUsersForRoom(_roomId),
            builder: (context, snapshot) {
              // While loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading active users...')
                    ],
                  ),
                );
              }

              // Error state
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text('Error occurred: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                );
              }

              // If data is empty
              final activeUsers = snapshot.data;
              if (activeUsers == null || activeUsers.isEmpty) {
                return Center(child: Text('No active session found.'));
              }

              // If data exists
              return ListView.builder(
                shrinkWrap: true,
                itemCount: activeUsers.length,
                itemBuilder: (context, index) {
                  final userSession = activeUsers[index];
                  if (userSession == null) return SizedBox.shrink(); // Null check

                  bool isCurrentUser = userSession.sessionId == widget.sessionId;

                  return ListTile(
                    leading: Icon(isCurrentUser ? Icons.person_pin : Icons.person_outline),
                    title: Text(isCurrentUser ? 'You (This Session)' : 'Other User'),
                    subtitle: Text('Session ID: ...${userSession.sessionId.substring(userSession.sessionId.length - 6)}'),
                    trailing: isCurrentUser
                        ? null
                        : IconButton(
                      icon: Icon(Icons.logout, color: Colors.red),
                      tooltip: 'Terminate Session',
                      onPressed: () async {
                        bool confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                             title: Text('Terminate Session'),
                            content: Text("Are you sure you want to terminate this user's session?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Terminate', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ) ?? false;

                        if (confirm) {
                          Navigator.pop(context);
                          await _terminateUserSession(userSession.sessionId);
                          _showActiveUsersDialog(); // Reopen to refresh the list
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Room Control Panel')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Room Control Panel', style: TextStyle(color: Colors.blue)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.people, color: Colors.blue),
            tooltip: 'Current Users',
            onPressed: _showActiveUsersDialog,
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.blue),
            tooltip: 'Settings',
            onPressed: _showSettingsDialog, // Show dialog instead of NavigationService
          ),
          AnimatedBuilder(
            animation: _isLoggingOut,
            builder: (context, child) {
              return IconButton(
                icon: _isLoggingOut.value
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.red,
                  ),
                )
                    : Icon(Icons.exit_to_app, color: Colors.red),
                tooltip: 'Terminate Session',
                onPressed: _isLoggingOut.value
                    ? null
                    : () async {
                  _isLoggingOut.value = true;
                  try {
                    // Terminate session process
                    await _terminateUserSession(widget.sessionId);

                    // Reset session info using updateAuthState method in NavigationService
                    ref.read(navigationServiceProvider).updateAuthState(
                        isAuthenticated: false,
                        roomId: null,
                        sessionId: null);

                    if (mounted) {
                      // Redirect to home page
                      ref.read(navigationServiceProvider).navigateToHome();
                    }
                  } finally {
                    if (mounted) {
                      _isLoggingOut.value = false;
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRoomHistory,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Greeting and status area - Adapted for Web
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
                            'Welcome, $_userName',
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
                            'Room Status: ${_isRoomOccupied ? "Occupied" : "Empty"} | Mode: $_roomMode',
                            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Live sensor data - Web-like responsive grid
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width > 1200
                        ? 280 // Fixed width on wide screens
                        : 218,
                          child: RoomStatusCard(
                            title: 'Temperature',
                            value: '${_currentTemperature.toStringAsFixed(1)}°C',
                            icon: Icons.thermostat,
                            color: _getSensorColor(_currentTemperature, 18, 25),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width > 1200
                              ? 280 // Fixed width on wide screens
                              : 218,
                          child: RoomStatusCard(
                            title: 'Humidity',
                            value: '${_currentHumidity.toStringAsFixed(1)}%',
                            icon: Icons.water_drop,
                            color: _getSensorColor(_currentHumidity, 40, 60),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width > 600
                              ? 280 // Fixed width on wide screens
                              : 218,
                          child: RoomStatusCard(
                            title: 'Gas Level',
                            value: '$_currentGasLevel/10',
                            icon: Icons.cloud,
                            color: _getGasColor(_currentGasLevel),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width > 600
                              ? 280 // Fixed width on wide screens
                              : 218,
                          child: RoomStatusCard(
                            title: 'Card Status',
                            value: _isCardInserted ? 'Inserted' : 'Not Inserted',
                            icon: Icons.credit_card,
                            color: _isCardInserted ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Room Control Section - Adapted for Web
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.room_preferences, color: Colors.blue, size: 28),
                                SizedBox(width: 8),
                                Text(
                                  'Room Controls',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),

                            // Lighting and Device Controls side by side - Responsive for Web
                            LayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.maxWidth > 800) {
                                    // Wide screen - side by side
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Lighting Controls
                                        Expanded(
                                          child: _buildLightingControls(),
                                        ),
                                        SizedBox(width: 24),
                                        // Device Controls
                                        Expanded(
                                          child: _buildDeviceControls(),
                                        ),
                                      ],
                                    );
                                  } else {
                                    // Narrow screen - one below the other
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLightingControls(),
                                        SizedBox(height: 24),
                                        _buildDeviceControls(),
                                      ],
                                    );
                                  }
                                }
                            ),

                            Divider(height: 40, thickness: 1),

                            // Service Buttons - Adapted for Web
                            Text(
                              'Services',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 16),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.start,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _showCleaningRequestDialog,
                                  icon: Icon(Icons.cleaning_services),
                                  label: Text('Request Cleaning'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    textStyle: TextStyle(fontSize: 16),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _showReceptionMessageDialog,
                                  icon: Icon(Icons.message),
                                  label: Text('Send Message to Reception'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    textStyle: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 32),

                    Center(child: _buildAIButton()),

                    SizedBox(height: 32),

                    // Sensor graphs - Adapted for Web
                    LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 900) {
                            // Wide screen - side by side graphs
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildTemperatureChart(),
                                ),
                                SizedBox(width: 24),
                                Expanded(
                                  child: _buildHumidityChart(),
                                ),
                              ],
                            );
                          } else {
                            // Narrow screen - one below the other graphs
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTemperatureChart(),
                                SizedBox(height: 32),
                                _buildHumidityChart(),
                              ],
                            );
                          }
                        }
                    ),

                    SizedBox(height: 32),

                    // Recent events - Adapted for Web
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.history, color: Colors.blue, size: 28),
                                SizedBox(width: 8),
                                Text(
                                  'Recent Events',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            EventList(events: _eventHistory),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Lighting controls widget
  Widget _buildLightingControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Lighting',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        ),
        SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              SwitchListTile(
                title: Text('Main Lighting'),
                value: _mainLightOn,
                secondary: Icon(Icons.lightbulb, color: _mainLightOn ? Colors.yellow : Colors.grey),
                onChanged: (value) => _toggleLight('main', value),
              ),
              Divider(height: 1),
              SwitchListTile(
                title: Text('Desk Light'),
                value: _deskLightOn,
                secondary: Icon(Icons.desk, color: _deskLightOn ? Colors.yellow : Colors.grey),
                onChanged: (value) => _toggleLight('desk', value),
              ),
              Divider(height: 1),
              SwitchListTile(
                title: Text('Bed Light'),
                value: _bedLightOn,
                secondary: Icon(Icons.bed, color: _bedLightOn ? Colors.yellow : Colors.grey),
                onChanged: (value) => _toggleLight('bed', value),
              ),
              Divider(height: 1),
              SwitchListTile(
                title: Text('Bathroom Light'),
                value: _bathroomLightOn,
                secondary: Icon(Icons.bathroom, color: _bathroomLightOn ? Colors.yellow : Colors.grey),
                onChanged: (value) => _toggleLight('bathroom', value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Device controls widget
  Widget _buildDeviceControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Devices',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        ),
        SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              SwitchListTile(
                title: Text('Television'),
                value: _tvOn,
                secondary: Icon(Icons.tv, color: _tvOn ? Colors.blue : Colors.grey),
                onChanged: (value) => _toggleDevice('tv', value),
              ),
              Divider(height: 1),
              SwitchListTile(
                title: Text('AC'),
                value: _acOn,
                secondary: Icon(Icons.ac_unit, color: _acOn ? Colors.blue : Colors.grey),
                onChanged: (value) => _toggleDevice('ac', value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Temperature graph widget
  Widget _buildTemperatureChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temperature Graph',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SensorChart(
                data: _temperatureHistory,
                color: Colors.orange,
                label: 'Temperature (°C)',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Humidity graph widget
  Widget _buildHumidityChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Humidity Graph',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SensorChart(
                data: _humidityHistory,
                color: Colors.blue,
                label: 'Humidity (%)',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIButton() {
    return AnimatedBuilder(
      animation: _aiButtonAnimController,
      builder: (context, child) {
        final Color currentColor = _aiAssistantEnabled
            ? _aiButtonColors[(_aiButtonAnimController.value * (_aiButtonColors.length - 1)).round()]
            : Colors.grey.shade600;

        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _toggleAI(!_aiAssistantEnabled),
            child: Container(
              width: 240,
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: _aiAssistantEnabled
                    ? LinearGradient(
                  colors: [currentColor.withValues(alpha: 0.7), currentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [Colors.grey.shade300, Colors.grey.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.smart_toy,
                    size: 48,
                    color: _aiAssistantEnabled ? Colors.white : Colors.grey.shade800,
                  ),
                  SizedBox(height: 12),
                  Text(
                    _aiAssistantEnabled ? 'AI Assistant Active' : 'AI Assistant Disabled',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _aiAssistantEnabled ? Colors.white : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}