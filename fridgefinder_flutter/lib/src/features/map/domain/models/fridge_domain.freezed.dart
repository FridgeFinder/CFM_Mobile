// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fridge_domain.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FridgeLocationDomain _$FridgeLocationDomainFromJson(Map<String, dynamic> json) {
  return _FridgeLocationDomain.fromJson(json);
}

/// @nodoc
mixin _$FridgeLocationDomain {
  String? get name => throw _privateConstructorUsedError;
  String get street => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  String get zip => throw _privateConstructorUsedError;
  double get geoLat => throw _privateConstructorUsedError;
  double get geoLng => throw _privateConstructorUsedError;

  /// Serializes this FridgeLocationDomain to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FridgeLocationDomain
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FridgeLocationDomainCopyWith<FridgeLocationDomain> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FridgeLocationDomainCopyWith<$Res> {
  factory $FridgeLocationDomainCopyWith(FridgeLocationDomain value,
          $Res Function(FridgeLocationDomain) then) =
      _$FridgeLocationDomainCopyWithImpl<$Res, FridgeLocationDomain>;
  @useResult
  $Res call(
      {String? name,
      String street,
      String city,
      String state,
      String zip,
      double geoLat,
      double geoLng});
}

/// @nodoc
class _$FridgeLocationDomainCopyWithImpl<$Res,
        $Val extends FridgeLocationDomain>
    implements $FridgeLocationDomainCopyWith<$Res> {
  _$FridgeLocationDomainCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FridgeLocationDomain
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? street = null,
    Object? city = null,
    Object? state = null,
    Object? zip = null,
    Object? geoLat = null,
    Object? geoLng = null,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      street: null == street
          ? _value.street
          : street // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      zip: null == zip
          ? _value.zip
          : zip // ignore: cast_nullable_to_non_nullable
              as String,
      geoLat: null == geoLat
          ? _value.geoLat
          : geoLat // ignore: cast_nullable_to_non_nullable
              as double,
      geoLng: null == geoLng
          ? _value.geoLng
          : geoLng // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FridgeLocationDomainImplCopyWith<$Res>
    implements $FridgeLocationDomainCopyWith<$Res> {
  factory _$$FridgeLocationDomainImplCopyWith(_$FridgeLocationDomainImpl value,
          $Res Function(_$FridgeLocationDomainImpl) then) =
      __$$FridgeLocationDomainImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      String street,
      String city,
      String state,
      String zip,
      double geoLat,
      double geoLng});
}

/// @nodoc
class __$$FridgeLocationDomainImplCopyWithImpl<$Res>
    extends _$FridgeLocationDomainCopyWithImpl<$Res, _$FridgeLocationDomainImpl>
    implements _$$FridgeLocationDomainImplCopyWith<$Res> {
  __$$FridgeLocationDomainImplCopyWithImpl(_$FridgeLocationDomainImpl _value,
      $Res Function(_$FridgeLocationDomainImpl) _then)
      : super(_value, _then);

  /// Create a copy of FridgeLocationDomain
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? street = null,
    Object? city = null,
    Object? state = null,
    Object? zip = null,
    Object? geoLat = null,
    Object? geoLng = null,
  }) {
    return _then(_$FridgeLocationDomainImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      street: null == street
          ? _value.street
          : street // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      zip: null == zip
          ? _value.zip
          : zip // ignore: cast_nullable_to_non_nullable
              as String,
      geoLat: null == geoLat
          ? _value.geoLat
          : geoLat // ignore: cast_nullable_to_non_nullable
              as double,
      geoLng: null == geoLng
          ? _value.geoLng
          : geoLng // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FridgeLocationDomainImpl extends _FridgeLocationDomain {
  const _$FridgeLocationDomainImpl(
      {this.name,
      this.street = '',
      this.city = '',
      this.state = '',
      this.zip = '',
      this.geoLat = 0.0,
      this.geoLng = 0.0})
      : super._();

  factory _$FridgeLocationDomainImpl.fromJson(Map<String, dynamic> json) =>
      _$$FridgeLocationDomainImplFromJson(json);

  @override
  final String? name;
  @override
  @JsonKey()
  final String street;
  @override
  @JsonKey()
  final String city;
  @override
  @JsonKey()
  final String state;
  @override
  @JsonKey()
  final String zip;
  @override
  @JsonKey()
  final double geoLat;
  @override
  @JsonKey()
  final double geoLng;

  @override
  String toString() {
    return 'FridgeLocationDomain(name: $name, street: $street, city: $city, state: $state, zip: $zip, geoLat: $geoLat, geoLng: $geoLng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FridgeLocationDomainImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.street, street) || other.street == street) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.zip, zip) || other.zip == zip) &&
            (identical(other.geoLat, geoLat) || other.geoLat == geoLat) &&
            (identical(other.geoLng, geoLng) || other.geoLng == geoLng));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, street, city, state, zip, geoLat, geoLng);

  /// Create a copy of FridgeLocationDomain
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FridgeLocationDomainImplCopyWith<_$FridgeLocationDomainImpl>
      get copyWith =>
          __$$FridgeLocationDomainImplCopyWithImpl<_$FridgeLocationDomainImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FridgeLocationDomainImplToJson(
      this,
    );
  }
}

abstract class _FridgeLocationDomain extends FridgeLocationDomain {
  const factory _FridgeLocationDomain(
      {final String? name,
      final String street,
      final String city,
      final String state,
      final String zip,
      final double geoLat,
      final double geoLng}) = _$FridgeLocationDomainImpl;
  const _FridgeLocationDomain._() : super._();

  factory _FridgeLocationDomain.fromJson(Map<String, dynamic> json) =
      _$FridgeLocationDomainImpl.fromJson;

  @override
  String? get name;
  @override
  String get street;
  @override
  String get city;
  @override
  String get state;
  @override
  String get zip;
  @override
  double get geoLat;
  @override
  double get geoLng;

  /// Create a copy of FridgeLocationDomain
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FridgeLocationDomainImplCopyWith<_$FridgeLocationDomainImpl>
      get copyWith => throw _privateConstructorUsedError;
}

FridgeMaintainerDomain _$FridgeMaintainerDomainFromJson(
    Map<String, dynamic> json) {
  return _FridgeMaintainerDomain.fromJson(json);
}

/// @nodoc
mixin _$FridgeMaintainerDomain {
  String? get name => throw _privateConstructorUsedError;
  String? get organization => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get instagram => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;

  /// Serializes this FridgeMaintainerDomain to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FridgeMaintainerDomain
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FridgeMaintainerDomainCopyWith<FridgeMaintainerDomain> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FridgeMaintainerDomainCopyWith<$Res> {
  factory $FridgeMaintainerDomainCopyWith(FridgeMaintainerDomain value,
          $Res Function(FridgeMaintainerDomain) then) =
      _$FridgeMaintainerDomainCopyWithImpl<$Res, FridgeMaintainerDomain>;
  @useResult
  $Res call(
      {String? name,
      String? organization,
      String? phone,
      String? email,
      String? instagram,
      String? website});
}

/// @nodoc
class _$FridgeMaintainerDomainCopyWithImpl<$Res,
        $Val extends FridgeMaintainerDomain>
    implements $FridgeMaintainerDomainCopyWith<$Res> {
  _$FridgeMaintainerDomainCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FridgeMaintainerDomain
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? organization = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? instagram = freezed,
    Object? website = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      organization: freezed == organization
          ? _value.organization
          : organization // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      instagram: freezed == instagram
          ? _value.instagram
          : instagram // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FridgeMaintainerDomainImplCopyWith<$Res>
    implements $FridgeMaintainerDomainCopyWith<$Res> {
  factory _$$FridgeMaintainerDomainImplCopyWith(
          _$FridgeMaintainerDomainImpl value,
          $Res Function(_$FridgeMaintainerDomainImpl) then) =
      __$$FridgeMaintainerDomainImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      String? organization,
      String? phone,
      String? email,
      String? instagram,
      String? website});
}

/// @nodoc
class __$$FridgeMaintainerDomainImplCopyWithImpl<$Res>
    extends _$FridgeMaintainerDomainCopyWithImpl<$Res,
        _$FridgeMaintainerDomainImpl>
    implements _$$FridgeMaintainerDomainImplCopyWith<$Res> {
  __$$FridgeMaintainerDomainImplCopyWithImpl(
      _$FridgeMaintainerDomainImpl _value,
      $Res Function(_$FridgeMaintainerDomainImpl) _then)
      : super(_value, _then);

  /// Create a copy of FridgeMaintainerDomain
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? organization = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? instagram = freezed,
    Object? website = freezed,
  }) {
    return _then(_$FridgeMaintainerDomainImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      organization: freezed == organization
          ? _value.organization
          : organization // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      instagram: freezed == instagram
          ? _value.instagram
          : instagram // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FridgeMaintainerDomainImpl extends _FridgeMaintainerDomain {
  const _$FridgeMaintainerDomainImpl(
      {this.name,
      this.organization,
      this.phone,
      this.email,
      this.instagram,
      this.website})
      : super._();

  factory _$FridgeMaintainerDomainImpl.fromJson(Map<String, dynamic> json) =>
      _$$FridgeMaintainerDomainImplFromJson(json);

  @override
  final String? name;
  @override
  final String? organization;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final String? instagram;
  @override
  final String? website;

  @override
  String toString() {
    return 'FridgeMaintainerDomain(name: $name, organization: $organization, phone: $phone, email: $email, instagram: $instagram, website: $website)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FridgeMaintainerDomainImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.organization, organization) ||
                other.organization == organization) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.instagram, instagram) ||
                other.instagram == instagram) &&
            (identical(other.website, website) || other.website == website));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, organization, phone, email, instagram, website);

  /// Create a copy of FridgeMaintainerDomain
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FridgeMaintainerDomainImplCopyWith<_$FridgeMaintainerDomainImpl>
      get copyWith => __$$FridgeMaintainerDomainImplCopyWithImpl<
          _$FridgeMaintainerDomainImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FridgeMaintainerDomainImplToJson(
      this,
    );
  }
}

abstract class _FridgeMaintainerDomain extends FridgeMaintainerDomain {
  const factory _FridgeMaintainerDomain(
      {final String? name,
      final String? organization,
      final String? phone,
      final String? email,
      final String? instagram,
      final String? website}) = _$FridgeMaintainerDomainImpl;
  const _FridgeMaintainerDomain._() : super._();

  factory _FridgeMaintainerDomain.fromJson(Map<String, dynamic> json) =
      _$FridgeMaintainerDomainImpl.fromJson;

  @override
  String? get name;
  @override
  String? get organization;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  String? get instagram;
  @override
  String? get website;

  /// Create a copy of FridgeMaintainerDomain
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FridgeMaintainerDomainImplCopyWith<_$FridgeMaintainerDomainImpl>
      get copyWith => throw _privateConstructorUsedError;
}

FridgeReportDomain _$FridgeReportDomainFromJson(Map<String, dynamic> json) {
  return _FridgeReportDomain.fromJson(json);
}

/// @nodoc
mixin _$FridgeReportDomain {
  String get fridgeId => throw _privateConstructorUsedError;
  @_FridgeConditionConverter()
  FridgeCondition get condition => throw _privateConstructorUsedError;
  double get foodPercentage => throw _privateConstructorUsedError; // 0-1 range
  String? get notes => throw _privateConstructorUsedError;
  String? get epochTimestamp =>
      throw _privateConstructorUsedError; // Unix epoch as string
  String? get timestamp => throw _privateConstructorUsedError;

  /// Serializes this FridgeReportDomain to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FridgeReportDomain
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FridgeReportDomainCopyWith<FridgeReportDomain> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FridgeReportDomainCopyWith<$Res> {
  factory $FridgeReportDomainCopyWith(
          FridgeReportDomain value, $Res Function(FridgeReportDomain) then) =
      _$FridgeReportDomainCopyWithImpl<$Res, FridgeReportDomain>;
  @useResult
  $Res call(
      {String fridgeId,
      @_FridgeConditionConverter() FridgeCondition condition,
      double foodPercentage,
      String? notes,
      String? epochTimestamp,
      String? timestamp});
}

/// @nodoc
class _$FridgeReportDomainCopyWithImpl<$Res, $Val extends FridgeReportDomain>
    implements $FridgeReportDomainCopyWith<$Res> {
  _$FridgeReportDomainCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FridgeReportDomain
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fridgeId = null,
    Object? condition = null,
    Object? foodPercentage = null,
    Object? notes = freezed,
    Object? epochTimestamp = freezed,
    Object? timestamp = freezed,
  }) {
    return _then(_value.copyWith(
      fridgeId: null == fridgeId
          ? _value.fridgeId
          : fridgeId // ignore: cast_nullable_to_non_nullable
              as String,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as FridgeCondition,
      foodPercentage: null == foodPercentage
          ? _value.foodPercentage
          : foodPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      epochTimestamp: freezed == epochTimestamp
          ? _value.epochTimestamp
          : epochTimestamp // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FridgeReportDomainImplCopyWith<$Res>
    implements $FridgeReportDomainCopyWith<$Res> {
  factory _$$FridgeReportDomainImplCopyWith(_$FridgeReportDomainImpl value,
          $Res Function(_$FridgeReportDomainImpl) then) =
      __$$FridgeReportDomainImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String fridgeId,
      @_FridgeConditionConverter() FridgeCondition condition,
      double foodPercentage,
      String? notes,
      String? epochTimestamp,
      String? timestamp});
}

/// @nodoc
class __$$FridgeReportDomainImplCopyWithImpl<$Res>
    extends _$FridgeReportDomainCopyWithImpl<$Res, _$FridgeReportDomainImpl>
    implements _$$FridgeReportDomainImplCopyWith<$Res> {
  __$$FridgeReportDomainImplCopyWithImpl(_$FridgeReportDomainImpl _value,
      $Res Function(_$FridgeReportDomainImpl) _then)
      : super(_value, _then);

  /// Create a copy of FridgeReportDomain
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fridgeId = null,
    Object? condition = null,
    Object? foodPercentage = null,
    Object? notes = freezed,
    Object? epochTimestamp = freezed,
    Object? timestamp = freezed,
  }) {
    return _then(_$FridgeReportDomainImpl(
      fridgeId: null == fridgeId
          ? _value.fridgeId
          : fridgeId // ignore: cast_nullable_to_non_nullable
              as String,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as FridgeCondition,
      foodPercentage: null == foodPercentage
          ? _value.foodPercentage
          : foodPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      epochTimestamp: freezed == epochTimestamp
          ? _value.epochTimestamp
          : epochTimestamp // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FridgeReportDomainImpl extends _FridgeReportDomain {
  const _$FridgeReportDomainImpl(
      {this.fridgeId = '',
      @_FridgeConditionConverter() required this.condition,
      this.foodPercentage = 0.0,
      this.notes,
      this.epochTimestamp,
      this.timestamp})
      : super._();

  factory _$FridgeReportDomainImpl.fromJson(Map<String, dynamic> json) =>
      _$$FridgeReportDomainImplFromJson(json);

  @override
  @JsonKey()
  final String fridgeId;
  @override
  @_FridgeConditionConverter()
  final FridgeCondition condition;
  @override
  @JsonKey()
  final double foodPercentage;
// 0-1 range
  @override
  final String? notes;
  @override
  final String? epochTimestamp;
// Unix epoch as string
  @override
  final String? timestamp;

  @override
  String toString() {
    return 'FridgeReportDomain(fridgeId: $fridgeId, condition: $condition, foodPercentage: $foodPercentage, notes: $notes, epochTimestamp: $epochTimestamp, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FridgeReportDomainImpl &&
            (identical(other.fridgeId, fridgeId) ||
                other.fridgeId == fridgeId) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.foodPercentage, foodPercentage) ||
                other.foodPercentage == foodPercentage) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.epochTimestamp, epochTimestamp) ||
                other.epochTimestamp == epochTimestamp) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fridgeId, condition,
      foodPercentage, notes, epochTimestamp, timestamp);

  /// Create a copy of FridgeReportDomain
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FridgeReportDomainImplCopyWith<_$FridgeReportDomainImpl> get copyWith =>
      __$$FridgeReportDomainImplCopyWithImpl<_$FridgeReportDomainImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FridgeReportDomainImplToJson(
      this,
    );
  }
}

abstract class _FridgeReportDomain extends FridgeReportDomain {
  const factory _FridgeReportDomain(
      {final String fridgeId,
      @_FridgeConditionConverter() required final FridgeCondition condition,
      final double foodPercentage,
      final String? notes,
      final String? epochTimestamp,
      final String? timestamp}) = _$FridgeReportDomainImpl;
  const _FridgeReportDomain._() : super._();

  factory _FridgeReportDomain.fromJson(Map<String, dynamic> json) =
      _$FridgeReportDomainImpl.fromJson;

  @override
  String get fridgeId;
  @override
  @_FridgeConditionConverter()
  FridgeCondition get condition;
  @override
  double get foodPercentage; // 0-1 range
  @override
  String? get notes;
  @override
  String? get epochTimestamp; // Unix epoch as string
  @override
  String? get timestamp;

  /// Create a copy of FridgeReportDomain
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FridgeReportDomainImplCopyWith<_$FridgeReportDomainImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FridgeDomain _$FridgeDomainFromJson(Map<String, dynamic> json) {
  return _FridgeDomain.fromJson(json);
}

/// @nodoc
mixin _$FridgeDomain {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get verified => throw _privateConstructorUsedError;
  FridgeLocationDomain get location => throw _privateConstructorUsedError;
  FridgeMaintainerDomain? get maintainer => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get photoUrl =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'last_edited')
  String? get lastEdited =>
      throw _privateConstructorUsedError; // Unix epoch timestamp as string
  FridgeReportDomain? get latestFridgeReport =>
      throw _privateConstructorUsedError;

  /// Serializes this FridgeDomain to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FridgeDomain
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FridgeDomainCopyWith<FridgeDomain> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FridgeDomainCopyWith<$Res> {
  factory $FridgeDomainCopyWith(
          FridgeDomain value, $Res Function(FridgeDomain) then) =
      _$FridgeDomainCopyWithImpl<$Res, FridgeDomain>;
  @useResult
  $Res call(
      {String id,
      String name,
      bool verified,
      FridgeLocationDomain location,
      FridgeMaintainerDomain? maintainer,
      String? notes,
      String? photoUrl,
      @JsonKey(name: 'last_edited') String? lastEdited,
      FridgeReportDomain? latestFridgeReport});

  $FridgeLocationDomainCopyWith<$Res> get location;
  $FridgeMaintainerDomainCopyWith<$Res>? get maintainer;
  $FridgeReportDomainCopyWith<$Res>? get latestFridgeReport;
}

/// @nodoc
class _$FridgeDomainCopyWithImpl<$Res, $Val extends FridgeDomain>
    implements $FridgeDomainCopyWith<$Res> {
  _$FridgeDomainCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FridgeDomain
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? verified = null,
    Object? location = null,
    Object? maintainer = freezed,
    Object? notes = freezed,
    Object? photoUrl = freezed,
    Object? lastEdited = freezed,
    Object? latestFridgeReport = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      verified: null == verified
          ? _value.verified
          : verified // ignore: cast_nullable_to_non_nullable
              as bool,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as FridgeLocationDomain,
      maintainer: freezed == maintainer
          ? _value.maintainer
          : maintainer // ignore: cast_nullable_to_non_nullable
              as FridgeMaintainerDomain?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lastEdited: freezed == lastEdited
          ? _value.lastEdited
          : lastEdited // ignore: cast_nullable_to_non_nullable
              as String?,
      latestFridgeReport: freezed == latestFridgeReport
          ? _value.latestFridgeReport
          : latestFridgeReport // ignore: cast_nullable_to_non_nullable
              as FridgeReportDomain?,
    ) as $Val);
  }

  /// Create a copy of FridgeDomain
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FridgeLocationDomainCopyWith<$Res> get location {
    return $FridgeLocationDomainCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }

  /// Create a copy of FridgeDomain
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FridgeMaintainerDomainCopyWith<$Res>? get maintainer {
    if (_value.maintainer == null) {
      return null;
    }

    return $FridgeMaintainerDomainCopyWith<$Res>(_value.maintainer!, (value) {
      return _then(_value.copyWith(maintainer: value) as $Val);
    });
  }

  /// Create a copy of FridgeDomain
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FridgeReportDomainCopyWith<$Res>? get latestFridgeReport {
    if (_value.latestFridgeReport == null) {
      return null;
    }

    return $FridgeReportDomainCopyWith<$Res>(_value.latestFridgeReport!,
        (value) {
      return _then(_value.copyWith(latestFridgeReport: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FridgeDomainImplCopyWith<$Res>
    implements $FridgeDomainCopyWith<$Res> {
  factory _$$FridgeDomainImplCopyWith(
          _$FridgeDomainImpl value, $Res Function(_$FridgeDomainImpl) then) =
      __$$FridgeDomainImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      bool verified,
      FridgeLocationDomain location,
      FridgeMaintainerDomain? maintainer,
      String? notes,
      String? photoUrl,
      @JsonKey(name: 'last_edited') String? lastEdited,
      FridgeReportDomain? latestFridgeReport});

  @override
  $FridgeLocationDomainCopyWith<$Res> get location;
  @override
  $FridgeMaintainerDomainCopyWith<$Res>? get maintainer;
  @override
  $FridgeReportDomainCopyWith<$Res>? get latestFridgeReport;
}

/// @nodoc
class __$$FridgeDomainImplCopyWithImpl<$Res>
    extends _$FridgeDomainCopyWithImpl<$Res, _$FridgeDomainImpl>
    implements _$$FridgeDomainImplCopyWith<$Res> {
  __$$FridgeDomainImplCopyWithImpl(
      _$FridgeDomainImpl _value, $Res Function(_$FridgeDomainImpl) _then)
      : super(_value, _then);

  /// Create a copy of FridgeDomain
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? verified = null,
    Object? location = null,
    Object? maintainer = freezed,
    Object? notes = freezed,
    Object? photoUrl = freezed,
    Object? lastEdited = freezed,
    Object? latestFridgeReport = freezed,
  }) {
    return _then(_$FridgeDomainImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      verified: null == verified
          ? _value.verified
          : verified // ignore: cast_nullable_to_non_nullable
              as bool,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as FridgeLocationDomain,
      maintainer: freezed == maintainer
          ? _value.maintainer
          : maintainer // ignore: cast_nullable_to_non_nullable
              as FridgeMaintainerDomain?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lastEdited: freezed == lastEdited
          ? _value.lastEdited
          : lastEdited // ignore: cast_nullable_to_non_nullable
              as String?,
      latestFridgeReport: freezed == latestFridgeReport
          ? _value.latestFridgeReport
          : latestFridgeReport // ignore: cast_nullable_to_non_nullable
              as FridgeReportDomain?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FridgeDomainImpl extends _FridgeDomain {
  const _$FridgeDomainImpl(
      {required this.id,
      required this.name,
      this.verified = false,
      required this.location,
      this.maintainer,
      this.notes,
      this.photoUrl,
      @JsonKey(name: 'last_edited') this.lastEdited,
      this.latestFridgeReport})
      : super._();

  factory _$FridgeDomainImpl.fromJson(Map<String, dynamic> json) =>
      _$$FridgeDomainImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final bool verified;
  @override
  final FridgeLocationDomain location;
  @override
  final FridgeMaintainerDomain? maintainer;
  @override
  final String? notes;
  @override
  final String? photoUrl;
// ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'last_edited')
  final String? lastEdited;
// Unix epoch timestamp as string
  @override
  final FridgeReportDomain? latestFridgeReport;

  @override
  String toString() {
    return 'FridgeDomain(id: $id, name: $name, verified: $verified, location: $location, maintainer: $maintainer, notes: $notes, photoUrl: $photoUrl, lastEdited: $lastEdited, latestFridgeReport: $latestFridgeReport)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FridgeDomainImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.verified, verified) ||
                other.verified == verified) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.maintainer, maintainer) ||
                other.maintainer == maintainer) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.lastEdited, lastEdited) ||
                other.lastEdited == lastEdited) &&
            (identical(other.latestFridgeReport, latestFridgeReport) ||
                other.latestFridgeReport == latestFridgeReport));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, verified, location,
      maintainer, notes, photoUrl, lastEdited, latestFridgeReport);

  /// Create a copy of FridgeDomain
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FridgeDomainImplCopyWith<_$FridgeDomainImpl> get copyWith =>
      __$$FridgeDomainImplCopyWithImpl<_$FridgeDomainImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FridgeDomainImplToJson(
      this,
    );
  }
}

abstract class _FridgeDomain extends FridgeDomain {
  const factory _FridgeDomain(
      {required final String id,
      required final String name,
      final bool verified,
      required final FridgeLocationDomain location,
      final FridgeMaintainerDomain? maintainer,
      final String? notes,
      final String? photoUrl,
      @JsonKey(name: 'last_edited') final String? lastEdited,
      final FridgeReportDomain? latestFridgeReport}) = _$FridgeDomainImpl;
  const _FridgeDomain._() : super._();

  factory _FridgeDomain.fromJson(Map<String, dynamic> json) =
      _$FridgeDomainImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  bool get verified;
  @override
  FridgeLocationDomain get location;
  @override
  FridgeMaintainerDomain? get maintainer;
  @override
  String? get notes;
  @override
  String? get photoUrl; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'last_edited')
  String? get lastEdited; // Unix epoch timestamp as string
  @override
  FridgeReportDomain? get latestFridgeReport;

  /// Create a copy of FridgeDomain
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FridgeDomainImplCopyWith<_$FridgeDomainImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
