import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_sanity/flutter_sanity.dart';
import 'package:flutter_sanity_image_url/flutter_sanity_image_url.dart';
import 'package:hopegoat/sanity_image.dart';
import 'dart:math';
import 'package:camera_extended/camera_extended.dart';
import 'dart:async';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

final sanityClient = SanityClient(projectId: "t3xfkiht", dataset: "production");

final navigatorKey = GlobalKey<NavigatorState>();

List<CameraDescription> cameras = [];
CameraController? _controller;
CameraAspectRatio _aspectRatio = CameraAspectRatio.ratio4x3;


void main() async {
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
    setState(() {
      _showCamera = !_showCamera;
    });
  }

  void _exit_capture() {
      setState(() {
      _showCamera = !_showCamera;
    });
  }

  void _skip() {
    if (skipCount < maxSkips) {
      setState(() {
        skip = true;
        skipCount = skipCount + 1;
      });
    }
  }

  String frameimgurl = "";
  String promptimgurl = "";
  String promptID = "promptID";

  int getNewRandIdx() {
    Random randomSkip = new Random();
    var newRandIdx = randomSkip.nextInt(_numHopeGoats);
    print(newRandIdx);
    if (allRandIdxs.contains(newRandIdx)) {
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
        child: _navIndex == 1
            ? (_showCamera == false
                  ? ListView(
                      children: [
                        FutureBuilder(
                          future: fetchHopeGoats(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: ErrorWidget(snapshot.error!),
                                );
                              }
                              if (snapshot.hasData) {
                                var hopegoats = snapshot.data as List;
                                var promptimgs = hopegoats
                                    .map(
                                      (hg) =>
                                          SanityImage.fromJson(hg["promptimg"]),
                                    )
                                    .toList();

                                var frameimgs = hopegoats
                                    .map(
                                      (hg) => SanityImage.fromJson(
                                        hg["captureframe"],
                                      ),
                                    )
                                    .toList();

                                if (skip == true) {
                                  randIdx = getNewRandIdx();
                                  allRandIdxs.add(randIdx);
                                  skip = false;
                                  print("SKIP $skipCount COMPLETE");
                                }

                                frameimgurl = urlFor(frameimgs[randIdx]).url();
                                promptimgurl = urlFor(
                                  promptimgs[randIdx],
                                ).url();
                                promptID = hopegoats[randIdx]["_id"];
                                print(promptID);

                                return (CachedNetworkImage(
                                  imageUrl: promptimgurl,
                                ));
                              }
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),

                        Container(
                          margin: EdgeInsets.all(5),
                          child: ElevatedButton(
                            onPressed: _capture,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(20),
                              textStyle: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Hopegoat',
                              ),
                              backgroundColor: const Color.fromARGB(
                                255,
                                241,
                                255,
                                147,
                              ),

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
                              textStyle: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Hopegoat',
                              ),
                              padding: const EdgeInsets.all(10),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: Color.fromARGB(
                                255,
                                255,
                                242,
                                197,
                              ),
                              //Color(0xFFFEC3E9),
                            ),
                            child: Text('Skip (${maxSkips - skipCount} Left)'),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      children: [
                        CapturingScreen(
                          frameURL: frameimgurl,
                          promptURL: promptimgurl,
                          promptID: promptID,
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: ElevatedButton(
                            onPressed: _exit_capture,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(15),
                              textStyle: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Hopegoat',
                              ),
                              backgroundColor: const Color.fromARGB(
                                255,
                                241,
                                255,
                                147,
                              ),

                              //Color(0xFFFE7D7A)
                              //Color(0xFFD6FBE8)
                            ),
                            child: Text('Exit'),
                          ),
                        ),
                      ],
                    ))
            : (_navIndex == 0
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: Text("~ Saved Captures ~", style: TextStyle(fontSize: 15),),
                          ),
                        ),
                                            Center(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                            child: Text("Coming Soon!", style: TextStyle(fontSize: 25),),
                          ),
                        ),
                        Image.asset(
                          "assets/images/icon.png",
                          height: 200,
                          fit: BoxFit.cover
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
                            child: Text(
                              textAlign: TextAlign.center,
                              "Right now, the best way to keep track of previous HopeGoats is to save them to your gallery. In the future, you will also be able to look through them here, and they will be sorted by date. :)",
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Center(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                            child: Text("All About", style: TextStyle(fontSize: 28),),
                          ),
                        ),
                        Image.asset(
                          "assets/images/HopegoatCloud.png",
                          height: 200,
                          fit: BoxFit.contain
                        ),
                        Padding(
                        padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: Image.asset("assets/images/AboutHopeGoat_1.png")),
                                                Padding(
                        padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                        child: Image.asset("assets/images/AboutHopeGoat_2.png")),
                                                Padding(
                        padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                        child: Image.asset("assets/images/AboutHopeGoat_3.png")),
                      ],
                    )),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightBlueAccent,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Captures',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
        currentIndex: _navIndex,
        selectedItemColor: Colors.lightBlue[900],
        onTap: _onNavItemTapped,
      ),
    );
  }
}

class CapturingScreen extends StatefulWidget {
  const CapturingScreen({
    super.key,
    // required this.camera,
    required this.frameURL,
    required this.promptURL,
    required this.promptID,
  });
  // final CameraDescription camera;
  final String frameURL;
  final String promptURL;
  final String promptID;

  @override
  CapturingScreenState createState() => CapturingScreenState();
}

class CapturingScreenState extends State<CapturingScreen> {
  bool _hideCam = false;

  @override
  void initState() {
    super.initState();
    _getAvailableCameras();
    _hideCam = false;
  }

  // get available cameras
  Future<void> _getAvailableCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    _initCamera(cameras.first);
  }

  Future<void> _initCamera(CameraDescription description) async {
    _controller = CameraController(
      description,
      ResolutionPreset.high,
      aspectRatio: _aspectRatio, // Set aspect ratio here
    );

    try {
      await _controller!.initialize();
      setState(() {});
    } catch (error) {
      print(error);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void _changeCameras() {
    final lensDirection = _controller?.description.lensDirection;
    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = cameras.firstWhere(
        (description) => description.lensDirection == CameraLensDirection.back,
      );
    } else {
      newDescription = cameras.firstWhere(
        (description) => description.lensDirection == CameraLensDirection.front,
      );
    }

    if (newDescription != null) {
      _initCamera(newDescription);
    }
  }

  bool _imageSaved = false;

  var showImagePath;

  _takePicture() async {
    final captured_image = await _controller?.takePicture();

    Directory imgDirectory = await getApplicationDocumentsDirectory();

    print(captured_image!.path);
    captured_image.saveTo(join(imgDirectory.path, "hopegoat_original.png"));

    final base_image = img.decodeImage(
      File(captured_image!.path).readAsBytesSync(),
    );

    var modifiedFrameURL = widget.frameURL.split("cdn.sanity.io");

    var resp = await http.get(Uri.https("cdn.sanity.io", modifiedFrameURL[1]));
    print(widget.frameURL);
    print("RESPONSE:");
    print(resp);

    File frameFile = new File(join(imgDirectory.path, "hopegoat_frame.png"));
    frameFile.writeAsBytesSync(resp.bodyBytes);

    final frame_image = img.decodeImage(
      File(join(imgDirectory.path, "hopegoat_frame.png")).readAsBytesSync(),
    );

    final mergedImage = img.Image(
      width: frame_image!.width,
      height: frame_image.height,
    );
    img.compositeImage(mergedImage, base_image!, dstW: frame_image.width);
    img.compositeImage(mergedImage, frame_image!, dstW: frame_image.width);

    final now = DateTime.now();
    var hopegoatpath = "HopeGoat-${now.toIso8601String()}.png";

    final HopeGoatFile = new File(join(imgDirectory.path, hopegoatpath));

    HopeGoatFile.writeAsBytesSync(img.encodePng(mergedImage));

    setState(() {
      showImagePath = join(imgDirectory.path, hopegoatpath);
      _imageSaved = true;
    });

    return showImagePath;
  }

  @override
  Widget build(BuildContext context) {
    // return(
    //   _controller?.value.isInitialized == true
    //               ? CameraPreview(_controller!)
    //               : const Center(child: CircularProgressIndicator())
    // );
    return (Column(
      children: [
        _hideCam == false
            ? Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 5,
                    child: _controller?.value.isInitialized == true
                        ? CameraPreview(_controller!)
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  CachedNetworkImage(imageUrl: widget.frameURL),
                ],
              )
            : CircularProgressIndicator(),
        _hideCam == false
            ? Container(
                margin: EdgeInsets.all(5),
                child: ElevatedButton(
                  onPressed: _changeCameras,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    textStyle: TextStyle(fontSize: 10, fontFamily: 'Hopegoat'),
                    backgroundColor: const Color.fromARGB(255, 241, 255, 147),

                    //Color(0xFFFE7D7A)
                    //Color(0xFFD6FBE8)
                  ),
                  child: Text("Change Direction"),
                ),
              )
            : Container(),
        _hideCam == false
            ? Container(
                margin: EdgeInsets.all(5),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        _hideCam = true;
                      });
                      await _takePicture();
                      // print("IMAGE PATH:");
                      // print(showImagePath);
                    } catch (error) {
                      print(error);
                    }
                    setState(() {
                      _hideCam = false;
                    });
                    // dispose();
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ShowPictureScreen(
                          mergedImgURL: showImagePath,
                          title: 'HopeGoat',
                          promptURL: widget.promptURL,
                          promptID: widget.promptID,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    textStyle: TextStyle(fontSize: 20, fontFamily: 'Hopegoat'),
                    backgroundColor: const Color.fromARGB(255, 241, 255, 147),

                    //Color(0xFFFE7D7A)
                    //Color(0xFFD6FBE8)
                  ),
                  child: Text('Capture'),
                ),
              )
            : Text("Loading Image..."),
      ],
    ));
  }
}

class ShowPictureScreen extends StatefulWidget {
  const ShowPictureScreen({
    super.key,
    // required this.camera,
    required this.mergedImgURL,
    required this.title,
    required this.promptURL,
    required this.promptID,
  });
  // final CameraDescription camera;
  final String mergedImgURL;
  final String title;
  final String promptURL;
  final String promptID;

  @override
  ShowPictureScreenState createState() => ShowPictureScreenState();
}

class ShowPictureScreenState extends State<ShowPictureScreen> {
  int _navIndex = 1;
  void _onNavItemTapped(int index) {
    setState(() {
      _navIndex = index;
    });
  }

  bool _fileSaved = false;
  bool _promptSaved = false;

  void _save() async {
    await Gal.putImage(widget.mergedImgURL);
    setState(() {
      _fileSaved = true;
    });
  }

  void _save_prompt() async {
    Directory imgDirectory = await getApplicationDocumentsDirectory();

    var modifiedPromptURL = widget.promptURL.split("cdn.sanity.io");

    var resp = await http.get(Uri.https("cdn.sanity.io", modifiedPromptURL[1]));
    print(widget.promptURL);

    var prompt_path = "hg-prompt-${widget.promptID}.png";

    File promptFile = new File(join(imgDirectory.path, prompt_path));
    promptFile.writeAsBytesSync(resp.bodyBytes);

    await Gal.putImage(join(imgDirectory.path, prompt_path));
    setState(() {
      _promptSaved = true;
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
      body: ListView(
        children: [
          _fileSaved == true
              ? Center(child: Text("File Saved to Gallery!"))
              : Container(),
          _promptSaved == true
              ? Center(child: Text("Prompt Saved to Gallery!"))
              : Container(),
          Image.file(File(widget.mergedImgURL)),
          Container(
            margin: EdgeInsets.all(5),
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                textStyle: TextStyle(fontSize: 20, fontFamily: 'Hopegoat'),
                backgroundColor: const Color.fromARGB(255, 241, 255, 147),

                //Color(0xFFFE7D7A)
                //Color(0xFFD6FBE8)
              ),
              child: Text('Save To Gallery'),
            ),
          ),
          Container(
            margin: EdgeInsets.all(5),
            child: ElevatedButton(
              onPressed: _save_prompt,
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(fontSize: 12, fontFamily: 'Hopegoat'),
                padding: const EdgeInsets.all(10),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Color.fromARGB(255, 255, 242, 197),
                //Color(0xFFFEC3E9),
              ),
              child: Text('Save Prompt Image'),
            ),
          ),
        ],
      ),
    );
  }
}
