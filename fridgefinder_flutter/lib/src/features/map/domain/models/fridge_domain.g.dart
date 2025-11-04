// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fridge_domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FridgeLocationDomain _$FridgeLocationDomainFromJson(
  Map<String, dynamic> json,
) => _FridgeLocationDomain(
  name: json['name'] as String?,
  street: json['street'] as String? ?? '',
  city: json['city'] as String? ?? '',
  state: json['state'] as String? ?? '',
  zip: json['zip'] as String? ?? '',
  geoLat: (json['geoLat'] as num?)?.toDouble() ?? 0.0,
  geoLng: (json['geoLng'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$FridgeLocationDomainToJson(
  _FridgeLocationDomain instance,
) => <String, dynamic>{
  'name': instance.name,
  'street': instance.street,
  'city': instance.city,
  'state': instance.state,
  'zip': instance.zip,
  'geoLat': instance.geoLat,
  'geoLng': instance.geoLng,
};

_FridgeMaintainerDomain _$FridgeMaintainerDomainFromJson(
  Map<String, dynamic> json,
) => _FridgeMaintainerDomain(
  name: json['name'] as String?,
  organization: json['organization'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  instagram: json['instagram'] as String?,
  website: json['website'] as String?,
);

Map<String, dynamic> _$FridgeMaintainerDomainToJson(
  _FridgeMaintainerDomain instance,
) => <String, dynamic>{
  'name': instance.name,
  'organization': instance.organization,
  'phone': instance.phone,
  'email': instance.email,
  'instagram': instance.instagram,
  'website': instance.website,
};

_FridgeReportDomain _$FridgeReportDomainFromJson(Map<String, dynamic> json) =>
    _FridgeReportDomain(
      fridgeId: json['fridgeId'] as String? ?? '',
      condition: const _FridgeConditionConverter().fromJson(
        json['condition'] as String,
      ),
      foodPercentage: (json['foodPercentage'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      epochTimestamp: json['epochTimestamp'] as String?,
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$FridgeReportDomainToJson(_FridgeReportDomain instance) =>
    <String, dynamic>{
      'fridgeId': instance.fridgeId,
      'condition': const _FridgeConditionConverter().toJson(instance.condition),
      'foodPercentage': instance.foodPercentage,
      'notes': instance.notes,
      'epochTimestamp': instance.epochTimestamp,
      'timestamp': instance.timestamp,
    };

_FridgeDomain _$FridgeDomainFromJson(Map<String, dynamic> json) =>
    _FridgeDomain(
      id: json['id'] as String,
      name: json['name'] as String,
      verified: json['verified'] as bool? ?? false,
      location: FridgeLocationDomain.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      maintainer: json['maintainer'] == null
          ? null
          : FridgeMaintainerDomain.fromJson(
              json['maintainer'] as Map<String, dynamic>,
            ),
      notes: json['notes'] as String?,
      photoUrl: json['photoUrl'] as String?,
      lastEdited: json['last_edited'] as String?,
      latestFridgeReport: json['latestFridgeReport'] == null
          ? null
          : FridgeReportDomain.fromJson(
              json['latestFridgeReport'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$FridgeDomainToJson(_FridgeDomain instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'verified': instance.verified,
      'location': instance.location,
      'maintainer': instance.maintainer,
      'notes': instance.notes,
      'photoUrl': instance.photoUrl,
      'last_edited': instance.lastEdited,
      'latestFridgeReport': instance.latestFridgeReport,
    };
