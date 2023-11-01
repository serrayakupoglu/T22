import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget{
  @override
  _SignupPageState createState() => _SignupPageState();
}
class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold( body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(15, 110, 0, 0),
                child: Text("SignUp",
                    style: TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold
                    )
                ),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 35, left: 20, right: 30),
          child: Column(
            children: <Widget>[
              const TextField(
                //controller: _emailController,
                decoration: InputDecoration(
                    labelText: 'EMAIL',
                    labelStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    )
                ),
              ),
              SizedBox(height: 20,),
              const TextField(
                //controller: _passwordController,
                decoration: InputDecoration(
                    labelText: 'PASSWORD',
                    labelStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    )
                ),
                obscureText: true,
              ),
              const SizedBox(height: 5.0,),
              const SizedBox(height: 40,),
              SizedBox(
                height: 40,
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  shadowColor: Colors.greenAccent,
                  color: Colors.black,
                  elevation: 7,
                  child: GestureDetector(
                      onTap: () async{
                  //      _register();
                      },
                      child: const Center(
                          child: Text(
                              'SIGNUP',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat'
                              )
                          )
                      )
                  ),
                ),
              ),
              const SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                        'Go Back',
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                        )
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    )
    );
  }
}