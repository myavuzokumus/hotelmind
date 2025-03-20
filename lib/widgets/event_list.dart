import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventList extends StatelessWidget {
  final List<Map<String, dynamic>> events;

  const EventList({
    Key? key,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Text('Henüz olay kaydı bulunmuyor'),
        ),
      );
    }

    return Container(
      height: 300,
      child: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _buildEventItem(context, event);
        },
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, Map<String, dynamic> event) {
    final eventType = event['type'] ?? event['eventType'] ?? 'UNKNOWN';
    final timestamp = event['timestamp'] != null
        ? DateTime.fromMillisecondsSinceEpoch(event['timestamp'])
        : DateTime.now();
    final String formattedTime = DateFormat('HH:mm:ss').format(timestamp);
    final String formattedDate = DateFormat('dd/MM/yyyy').format(timestamp);
    final description = event['description'] ?? event['details'] ?? 'Açıklama yok';

    // Olay tipine göre simge ve renk belirleme
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

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          _getEventTitle(eventType),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(description),
            SizedBox(height: 2),
            Text(
              '$formattedTime - $formattedDate',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () => _showEventDetails(context, event),
      ),
    );
  }

  String _getEventTitle(String eventType) {
    switch(eventType) {
      case 'CLIMATE_ACTION':
        return 'İklimlendirme İşlemi';
      case 'SECURITY_WARNING':
        return 'Güvenlik Uyarısı';
      case 'ALERT':
        return 'Alarm';
      case 'MODE_CHANGE':
        return 'Mod Değişimi';
      case 'ENTRY':
        return 'Giriş';
      case 'EXIT':
        return 'Çıkış';
      default:
        return 'Olay';
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
              Text('Açıklama:'),
              SizedBox(height: 8),
              Text(
                event['description'] ?? event['details'] ?? 'Açıklama yok',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Zaman:'),
              SizedBox(height: 8),
              Text(
                event['timestamp'] != null
                    ? DateFormat('dd/MM/yyyy HH:mm:ss').format(
                    DateTime.fromMillisecondsSinceEpoch(event['timestamp'])
                )
                    : 'Bilinmiyor',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (event['details'] is Map || event['mode'] != null || event['value'] != null)
                ...[
                  SizedBox(height: 16),
                  Text('Ek Bilgiler:'),
                  SizedBox(height: 8),
                  Text(
                    _getAdditionalInfo(event),
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Kapat'),
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
      buffer.writeln('Mod: ${event['mode']}');
    }

    if (event['value'] != null) {
      buffer.writeln('Değer: ${event['value']}');
    }

    return buffer.toString();
  }
}