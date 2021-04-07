import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_spinning_wheel/flutter_spinning_wheel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spinning_board/services/authService.dart';
import 'package:spinning_board/toApp.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(Phoenix(child: MyApp()));
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //   future: Firebase.initializeApp(),
    //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     } else {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //darkTheme: ThemeData.light(),
      // themeMode: ThemeMode.dark,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: AuthService().handleAuth(),
    );
    //   }
    // },
    //);
  }
}

const url = 'https://esokonimarkets.com';
launchURL() async =>
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final StreamController _dividerController = StreamController<int>();

  final _wheelNotifier = StreamController<double>();

  dispose() {
    _dividerController.close();
    _wheelNotifier.close();
    super.dispose();
  }

  bool buttonPressed = false;
  int updateData;
  update(int value) {
    firestore
        .collection('user')
        .doc(auth.currentUser.uid)
        .set({'value': value, 'spinned': true}, SetOptions(merge: true));
  }

  bool firstSpin;
  int info;
  checkfirstSpin() async {
    await firestore
        .collection('user')
        .doc(auth.currentUser.uid)
        .get()
        .then((value) {
      setState(() {
        info = value.data()['value'];
        firstSpin = value.data()['spinned'];
      });
    });
  }

  getuser() {
    return firestore.collection('user').doc(auth.currentUser.uid).get();
  }

  @override
  void initState() {
    checkfirstSpin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getuser(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return firstSpin
            ? Prize(
                data: info,
              )
            : Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.brown,
                  elevation: 0.0,
                  centerTitle: true,
                  title: Text(
                    'Spin The Wheel',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.exit_to_app),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (c) {
                                return CupertinoAlertDialog(
                                  content: Text('sign Out?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('stay')),
                                    TextButton(
                                        onPressed: () {
                                          AuthService().signOut();
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('signout'))
                                  ],
                                );
                              });
                        })
                  ],
                ),
                backgroundColor: Color(0xfff7f7f7),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(50),
                    child: Center(
                      child: Stack(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SpinningWheel(
                                    Image.asset(
                                        'assets/images/esokonispin.png'),
                                    width: 310,
                                    height: 310,
                                    initialSpinAngle: _generateRandomAngle(),
                                    spinResistance: 0.2,
                                    canInteractWhileSpinning: false,
                                    dividers: 8,
                                    onUpdate: _dividerController.add,
                                    // onEnd: _dividerController.add,
                                    onEnd: (val) {
                                      auth.currentUser == null
                                          ? Fluttertoast.showToast(
                                              timeInSecForIosWeb: 8,
                                              gravity: ToastGravity.CENTER,
                                              msg:
                                                  'please refresh your browser and signin again to spin the wheel')
                                          : print('');
                                      buttonPressed
                                          ? update(val)
                                          : print('could not update info');
                                      buttonPressed
                                          ? Navigator.of(context)
                                              .pushReplacement(
                                                  MaterialPageRoute(
                                                      builder: (bc) =>
                                                          Prize(data: val)))
                                              .then((value) {
                                              buttonPressed = false;
                                            })
                                          : Fluttertoast.showToast(
                                                  timeInSecForIosWeb: 2,
                                                  msg:
                                                      'Tap the "spin the wheel" button to stand a chance to win')
                                              .then((value) => print(
                                                  'spinned without button press'));
                                    },
                                    secondaryImageHeight: 190,
                                    secondaryImageWidth: 190,
                                    shouldStartOrStop: _wheelNotifier.stream,
                                  ),
                                  Image.asset(
                                    'assets/images/center.png',
                                    scale: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: ElevatedButton(
                                      child: Text("🎉Spin The Wheel🎉"),
                                      onPressed: () {
                                        buttonPressed = true;
                                        _wheelNotifier.sink
                                            .add(_generateRandomVelocity());
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              'Hey ' +
                                  auth.currentUser.email.split('@').first +
                                  ', Spin the Wheel and stand a chance to win one of these',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 30),
                          StreamBuilder(
                            stream: _dividerController.stream,
                            builder: (context, snapshot) {
                              return snapshot.hasData
                                  ? RouletteScore(snapshot.data)
                                  : Container();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }

  double _generateRandomVelocity() => (Random().nextDouble() * 20000) + 4000;

  double _generateRandomAngle() => Random().nextDouble() * pi * 2;
}

class RouletteScore extends StatelessWidget {
  final int selected;

  final Map<int, String> labels = {
    1: 'POCKET FRAGRANCE',
    2: 'THAT WAS CLOSE',
    3: 'BABY SHOWER CAP',
    4: 'BETTER LUCK NEXT TIME',
    5: 'TRY AGAIN',
    6: 'BELIEF',
    7: 'HAPPY SOCKS PAIR',
    8: 'NO LUCK TODAY',
  };

  RouletteScore(this.selected);

  @override
  Widget build(BuildContext context) {
    return Container();
    // return Text('${labels[selected]}',
    //     style: TextStyle(
    //         fontStyle: FontStyle.italic,
    //         fontSize: 24.0,
    //         fontWeight: FontWeight.w100));
  }
}
