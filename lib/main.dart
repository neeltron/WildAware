import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            Container(
            alignment: Alignment.center,
            child: Image.network(
              'https://sandycrazylocus.neeltron.repl.co/wildawaremain.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            alignment: const Alignment(0, 0.7),
            child: FlatButton(
              child: const Text('Get Started', style: TextStyle(fontSize: 20.0),),
              color: Colors.lightGreen,
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
          ],
        ),
      ),
    );
  }
}