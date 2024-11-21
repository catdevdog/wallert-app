import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkTheme = true;

  void _toggleTheme() {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallert',
      theme: isDarkTheme
          ? ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
          accentColor: Colors.pinkAccent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      )
          : ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
          accentColor: Colors.pinkAccent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Wallert', toggleTheme: _toggleTheme, isDarkTheme: isDarkTheme),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.toggleTheme, required this.isDarkTheme});

  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> _data = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // API 호출을 통해 데이터를 가져오는 메서드
  Future<void> _fetchData() async {
    final url = Uri.parse('https://kxx.kr:12225/api/v1/brands'); // API 서버의 URL을 입력합니다.
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 서버 응답이 성공적일 때 데이터 파싱
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _data = responseData['data'] ?? [];
          _isLoading = false;
        });
      } else {
        // 서버 응답이 실패했을 때
        setState(() {
          _errorMessage = 'Failed to load data. Please try again later.';
          _isLoading = false;
        });
      }
    } catch (e) {
      // 예외 처리
      setState(() {
        _errorMessage = 'An error occurred while fetching data.';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title),
            Row(
              children: [
                IconButton(
                  icon: Icon(widget.isDarkTheme ? Icons.wb_sunny : Icons.nights_stay),
                  onPressed: widget.toggleTheme,
                )
              ],
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : ListView.builder(
        itemCount: _data.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: ListTile(
              leading: Icon(
                Icons.account_circle,
                size: 50,
                color: widget.isDarkTheme ? Colors.white : Colors.black,
              ),
              title: Text(
                '${_data[index]['name']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                'ID: ${_data[index]['id']}',
                style: TextStyle(
                  color: widget.isDarkTheme ? Colors.white70 : Colors.black87,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward,
                color: widget.isDarkTheme ? Colors.white : Colors.black,
              ),
              onTap: () {
                // 카드 탭했을 때의 동작을 정의합니다.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Card ${_data[index]['name']} tapped!')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
