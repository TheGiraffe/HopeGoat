import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.lightBlue),
        fontFamily: 'Hopegoat',
      ),
      home: const MyHomePage(title: 'HopeGoat'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  int _hopegoatIndex = 0;
  final _maxindex = 1;
  void _capture() {}
  void _skip() {
    setState(() {
      if (_hopegoatIndex < _maxindex){
        _hopegoatIndex += 1;
      } else {
        _hopegoatIndex = 0;
      }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFacefff),
      //Color(0xFFacefff)
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: [
            Image(image: AssetImage('assets/images/HopeGoat_Placeholder${_hopegoatIndex.toString()}.png'),),
            Container(
              margin: EdgeInsets.all(5),
              child: ElevatedButton(
                onPressed: _capture,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  textStyle: TextStyle(fontSize: 20, fontFamily: 'Hopegoat'),
                  backgroundColor: const Color.fromARGB(255, 241, 255, 147),
                  //Color(0xFFFE7D7A)
                  //Color(0xFFD6FBE8)
                  
                ),
                child: Text('Capture'),
              ),
            ),
            Container(
              margin: EdgeInsets.all(5),
              child: ElevatedButton(
                onPressed: _skip,
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 12, fontFamily: 'Hopegoat'),
                  padding: const EdgeInsets.all(10),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: Color.fromARGB(255, 255, 242, 197),
                  //Color(0xFFFEC3E9),
                ),
                child: Text('Skip (3 Left)'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightBlueAccent,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Captures',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Tutorial'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightBlue[900],
        onTap: _onItemTapped,
      ),
    );
  }
}
