import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_sanity/flutter_sanity.dart';
import 'package:flutter_sanity_image_url/flutter_sanity_image_url.dart';
import 'package:hopegoat/sanity_image.dart';
import 'dart:math';
import 'package:camera/camera.dart';

final sanityClient = SanityClient(projectId: "t3xfkiht", dataset: "production");
late List<CameraDescription> _cameras;

void main(){
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

int _numHopeGoats = 0;

Random random = new Random();
var randIdx = random.nextInt(_numHopeGoats);
List allRandIdxs = [randIdx];

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _navIndex = 1;
  void _onNavItemTapped(int index) {
    setState(() {
      _navIndex = index;
    });
  }

  Future<dynamic> fetchHopeGoats() async {
    var query = r"*[_type=='hopegoat']";
    var response = await sanityClient.fetch(query);
    _numHopeGoats = response.length;
    return Future.value(response);
  }

  int skipCount = 0;
  var skip = false;
  int maxSkips = 3;

  bool _showCamera = false;

  void _capture() {
    _showCamera = true;
  }
  void _skip() {
    if (skipCount < maxSkips) {
      setState(() {
        skip = true;
        skipCount = skipCount + 1;
      });
    }
  }

  int getNewRandIdx(){
    Random randomSkip = new Random();
    var newRandIdx = randomSkip.nextInt(_numHopeGoats);
    print(newRandIdx);
    if (allRandIdxs.contains(newRandIdx)){
      newRandIdx = getNewRandIdx();
    }
    return newRandIdx;
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
        child: _navIndex == 1 ? (_showCamera == false ? ListView(
          children: [
            FutureBuilder(
              future: fetchHopeGoats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(child: ErrorWidget(snapshot.error!));
                  }
                  if (snapshot.hasData) {
                    var hopegoats = snapshot.data as List;
                    var promptimgs = hopegoats
                        .map((e) => SanityImage.fromJson(e["promptimg"]))
                        .toList();
                    
                    if (skip == true) {
                      randIdx = getNewRandIdx();
                      allRandIdxs.add(randIdx);
                      skip = false;
                      print("SKIP $skipCount COMPLETE");
                    }
                    
                    return (CachedNetworkImage(
                      imageUrl: urlFor(promptimgs[randIdx]).url(),
                    ));
                  }
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),

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
                child: Text('Skip (${maxSkips - skipCount} Left)'),
              ),
            ),
          ],
        ): Stack(children: [],)) : ListView(children: [],),
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
        currentIndex: _navIndex,
        selectedItemColor: Colors.lightBlue[900],
        onTap: _onNavItemTapped,
      ),
    );
  }
}
