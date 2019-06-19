import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FlutterMixpanel {
  static const MethodChannel _channel =
      const MethodChannel('net.amond.flutter_mixpanel');

  static const FlutterMixpanelPeople people = const FlutterMixpanelPeople();

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> initialize(String token) async {
    String response = await _channel.invokeMethod('initialize', token);
    debugPrint('response : $response');
    return response;
  }

  static Future<String> track(String event,
      [Map<String, dynamic> properties]) async {
    if (properties == null) {
      properties = {};
    }
    properties['__event'] = event;
    try {
      final response = await _channel.invokeMethod('track', properties);
      debugPrint('response : $response');
      return response;
    } catch (e) {
      debugPrint('track error $e');
      throw e;
    }
  }

  static Future<String> identify(String distinctId) async {
    final response = await _channel.invokeMethod('identify', distinctId);
    debugPrint('response : $response');
    return response;
  }

  static Future<void> flush() async {
    return await _channel.invokeMethod('flush');
  }
}

class FlutterMixpanelPeople {
  const FlutterMixpanelPeople();

  Future<void> set(Map<String, dynamic> properties) async {
    await FlutterMixpanel._channel
        .invokeMethod('people.setProperties', properties);
    return;
  }

  Future<void> setProperty(String property, dynamic to) async {
    await FlutterMixpanel._channel
        .invokeMethod('people.setProperty', {'property': property, 'to': to});
    return;
  }

  Future<void> setOnce(Map<String, dynamic> properties) async {
    await FlutterMixpanel._channel.invokeMethod('people.setOnce', properties);
    return;
  }

  Future<void> unset(List<String> properties) async {
    await FlutterMixpanel._channel.invokeMethod('people.unset', properties);
    return;
  }

  Future<void> append(Map<String, dynamic> properties) async {
    await FlutterMixpanel._channel.invokeMethod('people.append', properties);
    return;
  }

  Future<void> increment(Map<String, num> properties) async {
    await FlutterMixpanel._channel.invokeMethod('people.increment', properties);
    return;
  }

  Future<void> union(Map<String, num> properties) async {
    await FlutterMixpanel._channel.invokeMethod('people.union', properties);
    return;
  }
}
