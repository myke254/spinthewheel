import 'package:flutter/material.dart';
import 'package:spinning_board/services/authService.dart';

class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool passVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formkey,
          child: SingleChildScrollView(
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              child: Container(
                height: 400,
                width: 400,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Provide your Esokoni Email and Password to verify your Identity',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'email field should not be empty';
                            }
                            return null;
                          },
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.mail), hintText: 'email'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'passwords should not be empty';
                            }
                            return null;
                          },
                          onFieldSubmitted: (value) {
                            if (_formkey.currentState.validate()) {
                              print(
                                  'email is: ${emailController.text}\npassword is: ${passwordController.text}');
                              AuthService().signinuser(emailController.text,
                                  passwordController.text);
                            }
                          },
                          obscureText: !passVisible,
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  icon: Icon(Icons.remove_red_eye),
                                  onPressed: () {
                                    setState(() {
                                      if (passVisible) {
                                        passVisible = false;
                                      } else {
                                        passVisible = true;
                                      }
                                    });
                                  }),
                              prefixIcon: Icon(Icons.lock),
                              hintText: 'password'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton(
                            onPressed: () {
                              if (_formkey.currentState.validate()) {
                                print(
                                    'email is: ${emailController.text}\npassword is: ${passwordController.text}');
                                AuthService().signinuser(emailController.text,
                                    passwordController.text);
                              }
                            },
                            child: Text('Proceed')),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
