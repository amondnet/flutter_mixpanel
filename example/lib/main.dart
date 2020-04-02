import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixpanel/flutter_mixpanel.dart';

void main(List<String> args) {
  String token = 'b861b1f9e51d3eb4f4e8de98d978f748';

  /*
  if (args != null && args.isNotEmpty) {
    token = args[0];
  }*/
  runApp(MyApp(
    token: token,
  ));
}

class MyApp extends StatefulWidget {
  final String token;

  const MyApp({Key key, this.token}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await FlutterMixpanel.initialize(widget.token);
      await FlutterMixpanel.identify("test");
      //await FlutterMixpanel.people.set({'test': 'test'});
      await FlutterMixpanel.track("test_event", {
        'test': 'd',
        'mapType': {'d': 1},
        "dateType": DateTime.now(),
        "booleanType": true
      });

      await FlutterMixpanel.people.set({'boolValue': true});
      await FlutterMixpanel.people.append('appendTest', '1');

      await FlutterMixpanel.flush();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
