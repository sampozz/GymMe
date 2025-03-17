// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatLng _$LatLngFromJson(Map<String, dynamic> json) => LatLng(
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
);

Map<String, dynamic> _$LatLngToJson(LatLng instance) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
};

Gym _$GymFromJson(Map<String, dynamic> json) => Gym(
  address: json['address'] as String,
  id: json['id'] as String,
  image: json['image'] as String,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  name: json['name'] as String,
);

Map<String, dynamic> _$GymToJson(Gym instance) => <String, dynamic>{
  'address': instance.address,
  'id': instance.id,
  'image': instance.image,
  'lat': instance.lat,
  'lng': instance.lng,
  'name': instance.name,
};

Locations _$LocationsFromJson(Map<String, dynamic> json) => Locations(
  gyms:
      (json['gyms'] as List<dynamic>)
          .map((e) => Gym.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$LocationsToJson(Locations instance) => <String, dynamic>{
  'gyms': instance.gyms,
};
