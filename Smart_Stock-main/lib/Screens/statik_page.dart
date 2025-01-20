import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/statik_provider.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsProvider>(
      builder: (context, statistics, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('İstatistikler'),
            backgroundColor: const Color(0xFF1A237E),
          ),
          body: ListView.builder(
            itemCount: statistics.logs.length,
            itemBuilder: (context, index) {
              final log = statistics.logs[index];
              final timestamp = log['timestamp'] as DateTime;
              final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(timestamp);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(log['message']),
                  subtitle: Text(formattedDate),
                  leading: Icon(
                    log['isAddition'] ? Icons.add_circle : Icons.remove_circle,
                    color: log['isAddition'] ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
} 