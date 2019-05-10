import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mixpanel/flutter_mixpanel.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_mixpanel');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterMixpanel.platformVersion, '42');
  });
}
