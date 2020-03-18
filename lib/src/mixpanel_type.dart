import 'package:json_annotation/json_annotation.dart';

part 'mixpanel_type.g.dart';

Map<String, dynamic> parse(Map<String, dynamic> properties) {
  return properties.map((k, v) {
    if (v is bool || v is Uri) {
      return MapEntry(k, v.toString());
    } else if (v is DateTime) {
      return MapEntry(
          k, v.toIso8601String().replaceAll(RegExp(r"\.\d{3,6}Z?"), ""));
    } else {
      return MapEntry(k, v);
    }
  });
}

@JsonSerializable(explicitToJson: true)
class Property {
  final Map<String, dynamic> properties;

  Property(Map<String, dynamic> properties)
      : this.properties = parse(properties);

  factory Property.fromJson(Map<String, dynamic> json) =>
      _$PropertyFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Track extends Property {
  final String event;

  Track(this.event, {Map<String, dynamic> properties}) : super(properties);

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  Map<String, dynamic> toJson() => _$TrackToJson(this);
}

@JsonSerializable()
class Time {
  final String event;

  Time(this.event);

  factory Time.fromJson(Map<String, dynamic> json) => _$TimeFromJson(json);

  Map<String, dynamic> toJson() => _$TimeToJson(this);
}
