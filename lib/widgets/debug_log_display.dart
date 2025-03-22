import 'package:flutter/material.dart';
import '../services/debug_log_provider.dart';
import 'package:provider/provider.dart';

class DebugLogDisplay extends StatelessWidget {
  final bool expanded;

  const DebugLogDisplay({Key? key, this.expanded = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logProvider = Provider.of<DebugLogProvider>(context);
    final logs = logProvider.logs;

    return Container(
      constraints: BoxConstraints(
        maxHeight: expanded ? double.infinity : 200.0,
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Debug Logs',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.white, size: 20),
                onPressed: () => logProvider.clear(),
                tooltip: 'Logları Temizle',
              ),
            ],
          ),
          Divider(color: Colors.grey),
          Expanded(
            child: logs.isEmpty
                ? Center(
              child: Text(
                'Henüz log kaydı yok',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : Scrollbar(
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    logs[index],
                    style: TextStyle(
                      color: Colors.lightGreenAccent,
                      fontSize: 12.0,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}