import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:spinning_board/main.dart';
import 'package:spinning_board/services/authService.dart';

class Prize extends StatelessWidget {
  final data;

  const Prize({Key key, this.data}) : super(key: key);

  getdata() {
    switch (this.data) {
      case 1:
        return '🎉Congratulations..\nhere\'s your prize\n🎉Pocket Fragrance🎉';
        break;
      case 2:
        return 'That Was Close 🤦‍♂️';
        break;
      case 3:
        return '🎉Congratulations..\nhere\'s your prize\nBaby Shower Cap 🚿';
        break;
      case 4:
        return 'better luck next time 🤞🏽';
        break;
      case 5:
        return 'try again';
        break;
      case 6:
        return '🎉Congratulations..\nhere\'s your prize\nBELT😁';
        break;
      case 7:
        return '🎉Congratulations..\nhere\'s your prize\nhappy socks pair😊😊';
        break;
      case 8:
        return 'no luck today😌';
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        actions: [
          TextButton(
              onPressed: () {
                firestore
                    .collection('user')
                    .doc(auth.currentUser.uid)
                    .update({'spinned': false}).then((value) {
                  Phoenix.rebirth(context);
                  // Navigator.of(context).pushReplacement(
                  //     MaterialPageRoute(builder: (bc) => MyHomePage()));
                });
              },
              child: Text(
                'Try again😜',
              ))
        ],
      ),
      body: Container(
        child: Center(
            child: this.data == 5
                ? TextButton(
                    onPressed: () {
                      firestore
                          .collection('user')
                          .doc(auth.currentUser.uid)
                          .update({'spinned': false}).then((value) {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (bc) => MyHomePage()));
                      });
                    },
                    child: Text('try again😜'))
                : // Text(getdata().toString()),
                FutureBuilder(
                    future: Future.delayed(Duration(seconds: 2)),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          getdata().toString(),
                          textAlign: TextAlign.center,
                        );
                      } else {
                        launchURL();

                        return Text(
                          getdata().toString(),
                          textAlign: TextAlign.center,
                        );
                      }
                    },
                  )),
      ),
    );
  }
}
