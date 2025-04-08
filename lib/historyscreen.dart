import 'package:flutter/material.dart';
import 'package:test_intern/Database/postdb.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Map<String, dynamic>>> _historyList;
  final DatabasePost dbPost = DatabasePost();

  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('EEEE, d MMMM yyyy h:mm a');
    return formatter.format(dateTime);
  }

  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1985),
      lastDate: DateTime(2199),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });

      _historyList = dbPost.getFilteredHistory(
        startDate!,
        endDate!,
        startTime ?? TimeOfDay(hour: 0, minute: 0),
        endTime ?? TimeOfDay(hour: 23, minute: 59),
      );
    }
  }

  Future<void> _selectTimeRange() async {
    TimeOfDay? pickedStart = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
    );

    TimeOfDay? pickedEnd = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 23, minute: 59),
    );

    if (pickedStart != null && pickedEnd != null) {
      setState(() {
        startTime = pickedStart;
        endTime = pickedEnd;
      });

      _historyList = dbPost.getFilteredHistory(
        startDate!,
        endDate!,
        startTime!,
        endTime!,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _historyList = dbPost.getAll();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: Icon(Icons.access_time),
            onPressed: _selectTimeRange,
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Feed',
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: 22,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
        ),

        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _historyList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No history available.'));
            }

            final histories = snapshot.data!;
            return ListView.builder(
              itemCount: histories.length,
              itemBuilder: (context, index) {
                final history = histories[index];
                DateTime timestamp = DateTime.parse(history['timestamp']);
                String formattedTime = formatDateTime(timestamp);

                double latitude = history['latitude'] ?? 0.0;
                double longitude = history['longitude'] ?? 0.0;

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        spreadRadius: 1,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history['postTitle'] ?? 'No Title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        history['postBody'] ?? 'No Body',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Divider(),
                      SizedBox(height: 8),
                      Text(
                        'Visited at: $formattedTime',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        'Latitude: $latitude, Longitude: $longitude',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
