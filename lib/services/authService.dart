import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spinning_board/main.dart';
import 'package:spinning_board/signin.dart';
import 'package:http/http.dart' as http;

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class AuthService {
  //handles Auth
  handleAuth() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return MyHomePage();
          } else {
            return Signin();
          }
        });
  }

  signOut() {
    auth.signOut();
  }

  Future<void> signinuser(String email, String password) async {
    var url =
        //'https://mikewebapp.000webhostapp.com/esokoni/signin.php';
        "https://esokonimarkets.com/crossnetmeet/api/userauth/Api_esok.php?apicall=login";
    Map data = {
      "email": email,
      "password": password,
    };
    var res = await http.post(
      Uri.parse(url),
      body: data,
      headers: {"Accept": "application/json"},
    );

    try {
      if (res.statusCode == 200) {
        print(jsonDecode(res.body));
        // print('response ' + jsonDecode(res.body)['message']);

        if (jsonDecode(res.body.trim())['message'] ==
            'Invalid Email or password')
        // "invalid_username")
        {
          Fluttertoast.showToast(
              timeInSecForIosWeb: 5,
              msg: 'check your username or password',
              toastLength: Toast.LENGTH_LONG);
        } else {
          if (jsonDecode(res.body.trim())['message'] == 'Login successful'
              //'Login successful'
              ) {
            Fluttertoast.showToast(
                timeInSecForIosWeb: 5,
                msg: 'Signed in successfully',
                toastLength: Toast.LENGTH_LONG);
            try {
              auth
                  .signInWithEmailAndPassword(email: email, password: password)
                  .then((creds) {
                final User user = auth.currentUser;
                print(user.email + ' signed in successfully');
                firestore.collection('user').doc(user.uid).set({
                  'user': user.email,
                  'uid': user.uid,
                }, SetOptions(merge: true));
              }).catchError((error) {
                print(error.code);
                switch (error.code) {
                  case 'wrong-password':
                    Fluttertoast.showToast(msg: 'Wrong email or password');
                    break;
                  case 'user-not-found':
                    try {
                      auth
                          .createUserWithEmailAndPassword(
                              email: email, password: password)
                          .then((creds) {
                        User user = auth.currentUser;
                        firestore.collection('user').doc(user.uid).set({
                          'user': user.email,
                          'uid': user.uid,
                        }, SetOptions(merge: true));
                      });

                      return;
                    } catch (e) {
                      print('an error occurred' + e);

                      return null;
                    }
                    break;
                  case 'user-disabled':
                    Fluttertoast.showToast(msg: 'User disabled');
                    break;
                  default:
                    Fluttertoast.showToast(msg: error.code.toString());
                }
              });
            } catch (e) {
              print('an error occurred' + e);
              return null;
            }

            // Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(
            //         builder: (BuildContext context) => MyHomePage()));
          } else {
            Fluttertoast.showToast(
                msg: 'An error occurred try again later',
                toastLength: Toast.LENGTH_LONG);
          }
        }
      } else {
        print(res.statusCode);
        return;
      }
    } catch (e) {
      print('error ' + e);
      return;
    }

    // Fluttertoast.showToast(
    //     msg: 'Signed in successfully', toastLength: Toast.LENGTH_LONG);
    // sharedPreferences.setString("loggedin", 'yes');
    // sharedPreferences.setString("user_email", emailController.text);
    // sharedPreferences.setString("user_name", 'user');
    // Fluttertoast.showToast(
    //     msg: 'Signed in as ' + emailController.text,
    //     toastLength: Toast.LENGTH_LONG);
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (BuildContext context) => Home()));
  }
}
