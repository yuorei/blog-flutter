import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(BlogApp());
}

class BlogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ブログアプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ArticleListPage(),
    );
  }
}

class ArticleListPage extends StatefulWidget {
  @override
  _ArticleListPageState createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  List<dynamic> articles = [];

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    final url = dotenv.env['URL'];
    // urlのうしろに "!" をつける
    final response = await http.get(Uri.parse(url!));
    if (response.statusCode == 200) {
      // utf8.decode(response.bodyBytes) しないと文字化けしてしまう
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      if (jsonData is List<dynamic>) {
        setState(() {
          articles = jsonData;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('記事一覧'),
      ),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return ListTile(
            title: Text(article['title']),
            subtitle: Text(article['date']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailPage(article: article),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final dynamic article;

  ArticleDetailPage({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article['title']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article['date'],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              MarkdownBody(
                data: article['content'],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
