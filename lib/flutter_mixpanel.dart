import 'dart:async';

import 'package:flutter/services.dart';

class FlutterMixpanel {
  static const MethodChannel _channel =
      const MethodChannel('net.amond.flutter_mixpanel');

  static const FlutterMixpanelPeople people = const FlutterMixpanelPeople();

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> initialize(String token) async {
    await _channel.invokeMethod('initialize', token);
    return;
  }

  static Future<void> track(String event,
      [Map<String, dynamic> properties = const {}]) async {
    await _channel.invokeMethod('track', properties);
    return;
  }

  static Future<void> identify(String distinctId) async {
    await _channel.invokeMethod('identify', distinctId);
    return;
  }
}

class FlutterMixpanelPeople {
  const FlutterMixpanelPeople();

  static Future<void> set(Map<String, dynamic> properties) async {
    await FlutterMixpanel._channel.invokeMethod('people.set', properties);
    return;
  }

  static Future<void> setOnce(Map<String, dynamic> properties) async {
    await FlutterMixpanel._channel.invokeMethod('people.setOnce', properties);
    return;
  }

  static Future<void> unset(List<String> properties) async {
    await FlutterMixpanel._channel.invokeMethod('people.unset', properties);
    return;
  }

  static Future<void> append(Map<String, dynamic> properties) async {
    await FlutterMixpanel._channel.invokeMethod('people.append', properties);
    return;
  }

  static Future<void> increment(Map<String, num> properties) async {
    await FlutterMixpanel._channel.invokeMethod('people.increment', properties);
    return;
  }
}
