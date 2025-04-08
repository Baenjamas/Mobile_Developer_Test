import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CommentScreen extends StatefulWidget {
  final Map<String, dynamic> compost;

  const CommentScreen({Key? key, required this.compost}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CommentScreen();
  }
}

class _CommentScreen extends State<CommentScreen> {
  List<dynamic> comments = [];
  List<dynamic> filteredComments = [];

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    final commentsapi = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/comments'),
    );
    setState(() {
      comments = json.decode(commentsapi.body);
      filteredComments =
          comments
              .where((comment) => comment['postId'] == widget.compost['id'])
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.compost['title'] ?? 'Post')),
      body: CustomPaint(
        size: Size(double.infinity, double.infinity),
        painter: BackgroundPainter(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      spreadRadius: 1,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.compost['title'] ?? 'No Title',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(widget.compost['body'] ?? 'No Body'),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Text(
                'Comments:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color.fromARGB(255, 10, 10, 10),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredComments.length,
                  itemBuilder: (context, index) {
                    final _comments = filteredComments[index];
                    return Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _comments['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),

                          Text(
                            _comments['body'],
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
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
