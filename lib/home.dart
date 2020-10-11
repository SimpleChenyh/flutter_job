import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class BookItem extends StatefulWidget {
  @override
  _BookItemState createState() => _BookItemState();
}

class _BookItemState extends State<BookItem> {
  final _saved = Set<WordPair>();
  final _biggerFont = TextStyle(fontSize: 30.0);
  List<Book> items;

  Future getBookList() async {

    // var url = 'https://www.googleapis.com/books/v1/volumes?q={http}';
    var url = 'http://192.168.0.113:8080/ping';
    // var url = 'https://www.google.com/';
    var msg = "";

    // Await the http get response, then decode the json-formatted response.

    // Map<String, String> headers = Map();
    // headers[""] = "";

    var response = await http.get(url,headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      var bookMap = convert.jsonDecode(response.body) as List;
      List<Book> books = bookMap.map((jsonx) => Book.fromJson(jsonx)).toList();

      // List<Book> books = List.from(bookMap);
      var itemCount = books.length;
      setState(() {
        items = books;
      });
      msg = 'Number of books about http: $itemCount.';
    } else {
      msg = 'Request failed with status: ${response.statusCode}.';
    }
    print(msg);
  }

  @override
  void initState() {
    super.initState();
    getBookList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('The book you like'),
          actions: [
            IconButton(icon: Icon(Icons.filter_list), onPressed: _pushSaved),
          ],
        ),
        body: items == null
            ? Center(child: CircularProgressIndicator())
            : _buildBookList(items));
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
        builder: (BuildContext context) {
          final tiles = _saved.map(
            (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
              actions: <Widget>[
                Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: const Icon(Icons.message),
                      onPressed: () async {
                        var url =
                            'https://www.googleapis.com/books/v1/volumes?q={http}';
                        var msg = "";

                        // Await the http get response, then decode the json-formatted response.
                        var response = await http.get(url);
                        if (response.statusCode == 200) {
                          var jsonResponse = convert.jsonDecode(response.body);
                          var itemCount = jsonResponse['totalItems'];
                          msg = 'Number of books about http: $itemCount.';
                        } else {
                          msg =
                              'Request failed with status: ${response.statusCode}.';
                        }

                        final snackBar = SnackBar(content: Text(msg));
                        Scaffold.of(context).showSnackBar(snackBar);
                      },
                    );
                  },
                ),
              ],
            ),
            body: ListView(children: divided),
          );
        }, // ...to here.
      ),
    );
  }

  Widget _buildBookList(List items) {
    return Scrollbar(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (int index = 0; index < items.length; index++)
            ListTile(
              leading: ExcludeSemantics(
                child: CircleAvatar(child: Text('$index')),
              ),
              title: Text(items[index].title),
              subtitle: Text(items[index].auth),
            ),
        ],
      ),
    );
  }
}

class Book {
  String title;
  String auth;
  double price;

  Book({this.title, this.auth, this.price});

  Book.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    auth = json['auth'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['auth'] = this.auth;
    data['price'] = this.price;
    return data;
  }
}
