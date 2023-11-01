import 'package:flutter/material.dart';

class FirstPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FirstPageState();

}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                child: const Icon(Icons.music_note, color: Colors.white, size: 64),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(30, 30, 30, 30),
                child: TextField(
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    hintText: 'Email',
                    hintStyle: TextStyle(fontSize: 16),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none
                        )
                    ),
                    filled: true,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(30, 0, 30, 30),
                child: TextField(
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    hintText: 'Password',
                    hintStyle: TextStyle(fontSize: 16),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none
                        )
                    ),
                    filled: true,
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

}