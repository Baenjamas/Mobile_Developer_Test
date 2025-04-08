import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_intern/Database/postdb.dart';
import 'package:test_intern/commentscreen.dart';
import 'package:test_intern/historyscreen.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<StatefulWidget> createState() => _FeedScreen();
}

class _FeedScreen extends State<FeedScreen> {
  List<dynamic> posts = [];
  final DatabasePost dbPost = DatabasePost();

  @override
  void initState() {
    super.initState();
    dbPost.init();
    fetchPost();
  }

  Future<void> fetchPost() async {
    var postApi = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    );
    setState(() {
      posts = json.decode(postApi.body);
      posts.shuffle();
    });
  }

  void navigateToComments(BuildContext context, Map<String, dynamic> post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CommentScreen(compost: post)),
    );
  }

  void navigateToHistoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryPage()),
    );
  }

  Future<void> _recordHistory(String postTitle, String postBody) async {
    final db = DatabasePost();
    await db.init();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final history = {
        'postTitle': postTitle,
        'postBody': postBody,
        'timestamp': DateTime.now().toString(),
        'latitude': position.latitude,
        'longitude': position.longitude,
      };

      await db.insert(history);
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: fetchPost,
            child: Text(
              'Feed',
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: 22,
              ),
            ),
          ),
          TextButton(
            onPressed: navigateToHistoryPage,
            child: Text(
              'History',
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: 22,
              ),
            ),
          ),
        ],
      ),
      body: CustomPaint(
        size: Size(double.infinity, double.infinity),
        painter: BackgroundPainter(),
        child: Container(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var _post = posts[index];
              return GestureDetector(
                onTap: () async {
                  await _recordHistory(_post['title'], _post['body']);
                  navigateToComments(context, _post);
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(138, 127, 127, 1),
                        spreadRadius: 1,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _post['title'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(_post['body']),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.comment),
                            onPressed: () async {
                              await _recordHistory(
                                _post['title'],
                                _post['body'],
                              );
                              navigateToComments(context, _post);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color.fromARGB(255, 255, 255, 255)
          ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
