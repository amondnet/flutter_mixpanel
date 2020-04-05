import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixpanel/flutter_mixpanel.dart';

void main(List<String> args) {
  String token = 'bb2dad1143b6e62f0437b2b44bf1d820';

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
      await FlutterMixpanel.identify("test2");
      await FlutterMixpanel.people.identify('test2');

      await FlutterMixpanel.people.set({'test2': 'test2'});
      await FlutterMixpanel.people.setProperty('setProperyTest', 'ok');
      await FlutterMixpanel.people.setProperty('peopleBool', true);
      await FlutterMixpanel.people.append('append', 1);

      await FlutterMixpanel.people.set({'\$name': 'test2'});
      await FlutterMixpanel.people.set({'\$email': 'test@amond.net'});

      //await FlutterMixpanel.people.set({'test': DateTime.now()});

      await FlutterMixpanel.track("test_event", {
        'test': 'd',
        'mapType': {'d': 1},
        "dateType": DateTime.now(),
        'uri': Uri.parse('https://google.co.kr'),
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
