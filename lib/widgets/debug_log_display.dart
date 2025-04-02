// lib/widgets/debug_log_display.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmind/services/debug_log_provider.dart';

class DebugLogDisplay extends ConsumerWidget {
  final bool expanded;

  const DebugLogDisplay({super.key, this.expanded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(debugLogProvider);

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
          if (!expanded)
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
                  onPressed: () => ref.read(debugLogProvider.notifier).clear(),
                  tooltip: 'Logları Temizle',
                ),
              ],
            ),
          if (!expanded) Divider(color: Colors.grey),
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