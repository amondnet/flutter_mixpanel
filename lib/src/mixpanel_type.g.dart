// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mixpanel_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Property _$PropertyFromJson(Map<String, dynamic> json) {
  return Property(
    json['properties'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$PropertyToJson(Property instance) => <String, dynamic>{
      'properties': instance.properties,
    };

Track _$TrackFromJson(Map<String, dynamic> json) {
  return Track(
    json['event'] as String,
    properties: json['properties'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$TrackToJson(Track instance) => <String, dynamic>{
      'properties': instance.properties,
      'event': instance.event,
    };

Time _$TimeFromJson(Map<String, dynamic> json) {
  return Time(
    json['event'] as String,
  );
}

Map<String, dynamic> _$TimeToJson(Time instance) => <String, dynamic>{
      'event': instance.event,
    };
