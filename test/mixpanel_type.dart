import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_mixpanel/src/mixpanel_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mixpanel/flutter_mixpanel.dart';

void main() {
  setUp(() {});

  tearDown(() {});

  test('track', () async {
    // Given
    final eventName = "event";

    final track = Track(eventName, properties: {
      "bool": true,
      "string": "string",
      "int": 1,
      "double": 2.0,
      "DateTime": DateTime.now()
    });

    // Then
    expect(track.event, eventName);
    expect(track.properties!['bool'], "true");
    print(track.properties!['DateTime']);
    expect(track.properties!['DateTime'].runtimeType, String);
    expect(track.properties!['DateTime'].length, 19);
  });
}
