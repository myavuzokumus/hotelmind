// lib/widgets/event_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventList extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final double maxHeight;
  final bool showTitle;

  const EventList({
    super.key,
    required this.events,
    this.maxHeight = 300,
    this.showTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 48, color: Colors.grey.shade300),
              SizedBox(height: 16),
              Text(
                'No event records yet',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          const Text(
            'Recent Events',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          constraints: BoxConstraints(
            maxHeight: maxHeight,
          ),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            itemCount: events.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final event = events[events.length - 1 - index];
              return _buildEventItem(context, event);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventItem(BuildContext context, Map<String, dynamic> event) {
    final eventType = event['type'] ?? event['eventType'] ?? 'UNKNOWN';
    final timestamp = event['timestamp'] != null
        ? DateTime.fromMillisecondsSinceEpoch(event['timestamp']*1000)
        : DateTime.now();
    final String formattedTime = DateFormat('HH:mm:ss').format(timestamp);
    final String formattedDate = DateFormat('dd/MM/yyyy').format(timestamp);
    final description = event['description'] ?? event['details'] ?? 'No description';

    // Determine icon and color based on event type
    IconData icon;
    Color color;

    switch(eventType) {
      case 'CLIMATE_ACTION':
        icon = Icons.thermostat;
        color = Colors.blue;
        break;
      case 'SECURITY_WARNING':
        icon = Icons.security;
        color = Colors.red;
        break;
      case 'ALERT':
        icon = Icons.warning_amber;
        color = Colors.orange;
        break;
      case 'MODE_CHANGE':
        icon = Icons.settings;
        color = Colors.purple;
        break;
      case 'ENTRY':
        icon = Icons.login;
        color = Colors.green;
        break;
      case 'EXIT':
        icon = Icons.logout;
        color = Colors.teal;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return InkWell(
      onTap: () => _showEventDetails(context, event),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 4),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _getEventTitle(eventType),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEventTitle(String eventType) {
    switch(eventType) {
      case 'CLIMATE_ACTION':
        return 'Climate Action';
      case 'SECURITY_WARNING':
        return 'Security Warning';
      case 'ALERT':
        return 'Alert';
      case 'MODE_CHANGE':
        return 'Mode Change';
      case 'ENTRY':
        return 'Entry';
      case 'EXIT':
        return 'Exit';
      default:
        return 'Event';
    }
  }

  void _showEventDetails(BuildContext context, Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getEventTitle(event['type'] ?? event['eventType'] ?? 'UNKNOWN')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description:'),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  event['description'] ?? event['details'] ?? 'No description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16),
              Text('Time:'),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  event['timestamp'] != null
                      ? DateFormat('dd/MM/yyyy HH:mm:ss').format(
                      DateTime.fromMillisecondsSinceEpoch(event['timestamp'])
                  )
                      : 'Unknown',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (event['details'] is Map || event['mode'] != null || event['value'] != null)
                ...[
                  SizedBox(height: 16),
                  Text('Additional Info:'),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      _getAdditionalInfo(event),
                      style: TextStyle(fontFamily: 'monospace', fontSize: 14),
                    ),
                  ),
                ],
            ],
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

  String _getAdditionalInfo(Map<String, dynamic> event) {
    final StringBuffer buffer = StringBuffer();

    if (event['details'] is Map) {
      event['details'].forEach((key, value) {
        buffer.writeln('$key: $value');
      });
    }

    if (event['mode'] != null) {
      buffer.writeln('Mode: ${event['mode']}');
    }

    if (event['value'] != null) {
      buffer.writeln('Value: ${event['value']}');
    }

    return buffer.toString();
  }
}