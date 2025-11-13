// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fridge_domain.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FridgeLocationDomain {

 String? get name; String get street; String get city; String get state; String get zip; double get geoLat; double get geoLng;
/// Create a copy of FridgeLocationDomain
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FridgeLocationDomainCopyWith<FridgeLocationDomain> get copyWith => _$FridgeLocationDomainCopyWithImpl<FridgeLocationDomain>(this as FridgeLocationDomain, _$identity);

  /// Serializes this FridgeLocationDomain to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FridgeLocationDomain&&(identical(other.name, name) || other.name == name)&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.zip, zip) || other.zip == zip)&&(identical(other.geoLat, geoLat) || other.geoLat == geoLat)&&(identical(other.geoLng, geoLng) || other.geoLng == geoLng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,street,city,state,zip,geoLat,geoLng);

@override
String toString() {
  return 'FridgeLocationDomain(name: $name, street: $street, city: $city, state: $state, zip: $zip, geoLat: $geoLat, geoLng: $geoLng)';
}


}

/// @nodoc
abstract mixin class $FridgeLocationDomainCopyWith<$Res>  {
  factory $FridgeLocationDomainCopyWith(FridgeLocationDomain value, $Res Function(FridgeLocationDomain) _then) = _$FridgeLocationDomainCopyWithImpl;
@useResult
$Res call({
 String? name, String street, String city, String state, String zip, double geoLat, double geoLng
});




}
/// @nodoc
class _$FridgeLocationDomainCopyWithImpl<$Res>
    implements $FridgeLocationDomainCopyWith<$Res> {
  _$FridgeLocationDomainCopyWithImpl(this._self, this._then);

  final FridgeLocationDomain _self;
  final $Res Function(FridgeLocationDomain) _then;

/// Create a copy of FridgeLocationDomain
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? street = null,Object? city = null,Object? state = null,Object? zip = null,Object? geoLat = null,Object? geoLng = null,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,zip: null == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String,geoLat: null == geoLat ? _self.geoLat : geoLat // ignore: cast_nullable_to_non_nullable
as double,geoLng: null == geoLng ? _self.geoLng : geoLng // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [FridgeLocationDomain].
extension FridgeLocationDomainPatterns on FridgeLocationDomain {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FridgeLocationDomain value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FridgeLocationDomain() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FridgeLocationDomain value)  $default,){
final _that = this;
switch (_that) {
case _FridgeLocationDomain():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FridgeLocationDomain value)?  $default,){
final _that = this;
switch (_that) {
case _FridgeLocationDomain() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String street,  String city,  String state,  String zip,  double geoLat,  double geoLng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FridgeLocationDomain() when $default != null:
return $default(_that.name,_that.street,_that.city,_that.state,_that.zip,_that.geoLat,_that.geoLng);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String street,  String city,  String state,  String zip,  double geoLat,  double geoLng)  $default,) {final _that = this;
switch (_that) {
case _FridgeLocationDomain():
return $default(_that.name,_that.street,_that.city,_that.state,_that.zip,_that.geoLat,_that.geoLng);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String street,  String city,  String state,  String zip,  double geoLat,  double geoLng)?  $default,) {final _that = this;
switch (_that) {
case _FridgeLocationDomain() when $default != null:
return $default(_that.name,_that.street,_that.city,_that.state,_that.zip,_that.geoLat,_that.geoLng);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FridgeLocationDomain extends FridgeLocationDomain {
  const _FridgeLocationDomain({this.name, this.street = '', this.city = '', this.state = '', this.zip = '', this.geoLat = 0.0, this.geoLng = 0.0}): super._();
  factory _FridgeLocationDomain.fromJson(Map<String, dynamic> json) => _$FridgeLocationDomainFromJson(json);

@override final  String? name;
@override@JsonKey() final  String street;
@override@JsonKey() final  String city;
@override@JsonKey() final  String state;
@override@JsonKey() final  String zip;
@override@JsonKey() final  double geoLat;
@override@JsonKey() final  double geoLng;

/// Create a copy of FridgeLocationDomain
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FridgeLocationDomainCopyWith<_FridgeLocationDomain> get copyWith => __$FridgeLocationDomainCopyWithImpl<_FridgeLocationDomain>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FridgeLocationDomainToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FridgeLocationDomain&&(identical(other.name, name) || other.name == name)&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.zip, zip) || other.zip == zip)&&(identical(other.geoLat, geoLat) || other.geoLat == geoLat)&&(identical(other.geoLng, geoLng) || other.geoLng == geoLng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,street,city,state,zip,geoLat,geoLng);

@override
String toString() {
  return 'FridgeLocationDomain(name: $name, street: $street, city: $city, state: $state, zip: $zip, geoLat: $geoLat, geoLng: $geoLng)';
}


}

/// @nodoc
abstract mixin class _$FridgeLocationDomainCopyWith<$Res> implements $FridgeLocationDomainCopyWith<$Res> {
  factory _$FridgeLocationDomainCopyWith(_FridgeLocationDomain value, $Res Function(_FridgeLocationDomain) _then) = __$FridgeLocationDomainCopyWithImpl;
@override @useResult
$Res call({
 String? name, String street, String city, String state, String zip, double geoLat, double geoLng
});




}
/// @nodoc
class __$FridgeLocationDomainCopyWithImpl<$Res>
    implements _$FridgeLocationDomainCopyWith<$Res> {
  __$FridgeLocationDomainCopyWithImpl(this._self, this._then);

  final _FridgeLocationDomain _self;
  final $Res Function(_FridgeLocationDomain) _then;

/// Create a copy of FridgeLocationDomain
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? street = null,Object? city = null,Object? state = null,Object? zip = null,Object? geoLat = null,Object? geoLng = null,}) {
  return _then(_FridgeLocationDomain(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,zip: null == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String,geoLat: null == geoLat ? _self.geoLat : geoLat // ignore: cast_nullable_to_non_nullable
as double,geoLng: null == geoLng ? _self.geoLng : geoLng // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$FridgeMaintainerDomain {

 String? get name; String? get organization; String? get phone; String? get email; String? get instagram; String? get website;
/// Create a copy of FridgeMaintainerDomain
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FridgeMaintainerDomainCopyWith<FridgeMaintainerDomain> get copyWith => _$FridgeMaintainerDomainCopyWithImpl<FridgeMaintainerDomain>(this as FridgeMaintainerDomain, _$identity);

  /// Serializes this FridgeMaintainerDomain to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FridgeMaintainerDomain&&(identical(other.name, name) || other.name == name)&&(identical(other.organization, organization) || other.organization == organization)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.instagram, instagram) || other.instagram == instagram)&&(identical(other.website, website) || other.website == website));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,organization,phone,email,instagram,website);

@override
String toString() {
  return 'FridgeMaintainerDomain(name: $name, organization: $organization, phone: $phone, email: $email, instagram: $instagram, website: $website)';
}


}

/// @nodoc
abstract mixin class $FridgeMaintainerDomainCopyWith<$Res>  {
  factory $FridgeMaintainerDomainCopyWith(FridgeMaintainerDomain value, $Res Function(FridgeMaintainerDomain) _then) = _$FridgeMaintainerDomainCopyWithImpl;
@useResult
$Res call({
 String? name, String? organization, String? phone, String? email, String? instagram, String? website
});




}
/// @nodoc
class _$FridgeMaintainerDomainCopyWithImpl<$Res>
    implements $FridgeMaintainerDomainCopyWith<$Res> {
  _$FridgeMaintainerDomainCopyWithImpl(this._self, this._then);

  final FridgeMaintainerDomain _self;
  final $Res Function(FridgeMaintainerDomain) _then;

/// Create a copy of FridgeMaintainerDomain
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? organization = freezed,Object? phone = freezed,Object? email = freezed,Object? instagram = freezed,Object? website = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,instagram: freezed == instagram ? _self.instagram : instagram // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FridgeMaintainerDomain].
extension FridgeMaintainerDomainPatterns on FridgeMaintainerDomain {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FridgeMaintainerDomain value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FridgeMaintainerDomain() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FridgeMaintainerDomain value)  $default,){
final _that = this;
switch (_that) {
case _FridgeMaintainerDomain():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FridgeMaintainerDomain value)?  $default,){
final _that = this;
switch (_that) {
case _FridgeMaintainerDomain() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? organization,  String? phone,  String? email,  String? instagram,  String? website)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FridgeMaintainerDomain() when $default != null:
return $default(_that.name,_that.organization,_that.phone,_that.email,_that.instagram,_that.website);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? organization,  String? phone,  String? email,  String? instagram,  String? website)  $default,) {final _that = this;
switch (_that) {
case _FridgeMaintainerDomain():
return $default(_that.name,_that.organization,_that.phone,_that.email,_that.instagram,_that.website);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? organization,  String? phone,  String? email,  String? instagram,  String? website)?  $default,) {final _that = this;
switch (_that) {
case _FridgeMaintainerDomain() when $default != null:
return $default(_that.name,_that.organization,_that.phone,_that.email,_that.instagram,_that.website);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FridgeMaintainerDomain extends FridgeMaintainerDomain {
  const _FridgeMaintainerDomain({this.name, this.organization, this.phone, this.email, this.instagram, this.website}): super._();
  factory _FridgeMaintainerDomain.fromJson(Map<String, dynamic> json) => _$FridgeMaintainerDomainFromJson(json);

@override final  String? name;
@override final  String? organization;
@override final  String? phone;
@override final  String? email;
@override final  String? instagram;
@override final  String? website;

/// Create a copy of FridgeMaintainerDomain
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FridgeMaintainerDomainCopyWith<_FridgeMaintainerDomain> get copyWith => __$FridgeMaintainerDomainCopyWithImpl<_FridgeMaintainerDomain>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FridgeMaintainerDomainToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FridgeMaintainerDomain&&(identical(other.name, name) || other.name == name)&&(identical(other.organization, organization) || other.organization == organization)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.instagram, instagram) || other.instagram == instagram)&&(identical(other.website, website) || other.website == website));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,organization,phone,email,instagram,website);

@override
String toString() {
  return 'FridgeMaintainerDomain(name: $name, organization: $organization, phone: $phone, email: $email, instagram: $instagram, website: $website)';
}


}

/// @nodoc
abstract mixin class _$FridgeMaintainerDomainCopyWith<$Res> implements $FridgeMaintainerDomainCopyWith<$Res> {
  factory _$FridgeMaintainerDomainCopyWith(_FridgeMaintainerDomain value, $Res Function(_FridgeMaintainerDomain) _then) = __$FridgeMaintainerDomainCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? organization, String? phone, String? email, String? instagram, String? website
});




}
/// @nodoc
class __$FridgeMaintainerDomainCopyWithImpl<$Res>
    implements _$FridgeMaintainerDomainCopyWith<$Res> {
  __$FridgeMaintainerDomainCopyWithImpl(this._self, this._then);

  final _FridgeMaintainerDomain _self;
  final $Res Function(_FridgeMaintainerDomain) _then;

/// Create a copy of FridgeMaintainerDomain
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? organization = freezed,Object? phone = freezed,Object? email = freezed,Object? instagram = freezed,Object? website = freezed,}) {
  return _then(_FridgeMaintainerDomain(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,instagram: freezed == instagram ? _self.instagram : instagram // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FridgeReportDomain {

 String get fridgeId;@_FridgeConditionConverter() FridgeCondition get condition;@_FoodPercentageConverter() double get foodPercentage;// 0-1 range, clamped
 String? get notes; String? get photoUrl; String? get epochTimestamp;// Unix epoch as string
 String? get timestamp;
/// Create a copy of FridgeReportDomain
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FridgeReportDomainCopyWith<FridgeReportDomain> get copyWith => _$FridgeReportDomainCopyWithImpl<FridgeReportDomain>(this as FridgeReportDomain, _$identity);

  /// Serializes this FridgeReportDomain to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FridgeReportDomain&&(identical(other.fridgeId, fridgeId) || other.fridgeId == fridgeId)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.foodPercentage, foodPercentage) || other.foodPercentage == foodPercentage)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.epochTimestamp, epochTimestamp) || other.epochTimestamp == epochTimestamp)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fridgeId,condition,foodPercentage,notes,photoUrl,epochTimestamp,timestamp);

@override
String toString() {
  return 'FridgeReportDomain(fridgeId: $fridgeId, condition: $condition, foodPercentage: $foodPercentage, notes: $notes, photoUrl: $photoUrl, epochTimestamp: $epochTimestamp, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $FridgeReportDomainCopyWith<$Res>  {
  factory $FridgeReportDomainCopyWith(FridgeReportDomain value, $Res Function(FridgeReportDomain) _then) = _$FridgeReportDomainCopyWithImpl;
@useResult
$Res call({
 String fridgeId,@_FridgeConditionConverter() FridgeCondition condition,@_FoodPercentageConverter() double foodPercentage, String? notes, String? photoUrl, String? epochTimestamp, String? timestamp
});




}
/// @nodoc
class _$FridgeReportDomainCopyWithImpl<$Res>
    implements $FridgeReportDomainCopyWith<$Res> {
  _$FridgeReportDomainCopyWithImpl(this._self, this._then);

  final FridgeReportDomain _self;
  final $Res Function(FridgeReportDomain) _then;

/// Create a copy of FridgeReportDomain
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fridgeId = null,Object? condition = null,Object? foodPercentage = null,Object? notes = freezed,Object? photoUrl = freezed,Object? epochTimestamp = freezed,Object? timestamp = freezed,}) {
  return _then(_self.copyWith(
fridgeId: null == fridgeId ? _self.fridgeId : fridgeId // ignore: cast_nullable_to_non_nullable
as String,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as FridgeCondition,foodPercentage: null == foodPercentage ? _self.foodPercentage : foodPercentage // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,epochTimestamp: freezed == epochTimestamp ? _self.epochTimestamp : epochTimestamp // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FridgeReportDomain].
extension FridgeReportDomainPatterns on FridgeReportDomain {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FridgeReportDomain value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FridgeReportDomain() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FridgeReportDomain value)  $default,){
final _that = this;
switch (_that) {
case _FridgeReportDomain():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FridgeReportDomain value)?  $default,){
final _that = this;
switch (_that) {
case _FridgeReportDomain() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fridgeId, @_FridgeConditionConverter()  FridgeCondition condition, @_FoodPercentageConverter()  double foodPercentage,  String? notes,  String? photoUrl,  String? epochTimestamp,  String? timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FridgeReportDomain() when $default != null:
return $default(_that.fridgeId,_that.condition,_that.foodPercentage,_that.notes,_that.photoUrl,_that.epochTimestamp,_that.timestamp);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fridgeId, @_FridgeConditionConverter()  FridgeCondition condition, @_FoodPercentageConverter()  double foodPercentage,  String? notes,  String? photoUrl,  String? epochTimestamp,  String? timestamp)  $default,) {final _that = this;
switch (_that) {
case _FridgeReportDomain():
return $default(_that.fridgeId,_that.condition,_that.foodPercentage,_that.notes,_that.photoUrl,_that.epochTimestamp,_that.timestamp);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fridgeId, @_FridgeConditionConverter()  FridgeCondition condition, @_FoodPercentageConverter()  double foodPercentage,  String? notes,  String? photoUrl,  String? epochTimestamp,  String? timestamp)?  $default,) {final _that = this;
switch (_that) {
case _FridgeReportDomain() when $default != null:
return $default(_that.fridgeId,_that.condition,_that.foodPercentage,_that.notes,_that.photoUrl,_that.epochTimestamp,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FridgeReportDomain extends FridgeReportDomain {
  const _FridgeReportDomain({this.fridgeId = '', @_FridgeConditionConverter() required this.condition, @_FoodPercentageConverter() this.foodPercentage = 0.0, this.notes, this.photoUrl, this.epochTimestamp, this.timestamp}): super._();
  factory _FridgeReportDomain.fromJson(Map<String, dynamic> json) => _$FridgeReportDomainFromJson(json);

@override@JsonKey() final  String fridgeId;
@override@_FridgeConditionConverter() final  FridgeCondition condition;
@override@JsonKey()@_FoodPercentageConverter() final  double foodPercentage;
// 0-1 range, clamped
@override final  String? notes;
@override final  String? photoUrl;
@override final  String? epochTimestamp;
// Unix epoch as string
@override final  String? timestamp;

/// Create a copy of FridgeReportDomain
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FridgeReportDomainCopyWith<_FridgeReportDomain> get copyWith => __$FridgeReportDomainCopyWithImpl<_FridgeReportDomain>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FridgeReportDomainToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FridgeReportDomain&&(identical(other.fridgeId, fridgeId) || other.fridgeId == fridgeId)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.foodPercentage, foodPercentage) || other.foodPercentage == foodPercentage)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.epochTimestamp, epochTimestamp) || other.epochTimestamp == epochTimestamp)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fridgeId,condition,foodPercentage,notes,photoUrl,epochTimestamp,timestamp);

@override
String toString() {
  return 'FridgeReportDomain(fridgeId: $fridgeId, condition: $condition, foodPercentage: $foodPercentage, notes: $notes, photoUrl: $photoUrl, epochTimestamp: $epochTimestamp, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$FridgeReportDomainCopyWith<$Res> implements $FridgeReportDomainCopyWith<$Res> {
  factory _$FridgeReportDomainCopyWith(_FridgeReportDomain value, $Res Function(_FridgeReportDomain) _then) = __$FridgeReportDomainCopyWithImpl;
@override @useResult
$Res call({
 String fridgeId,@_FridgeConditionConverter() FridgeCondition condition,@_FoodPercentageConverter() double foodPercentage, String? notes, String? photoUrl, String? epochTimestamp, String? timestamp
});




}
/// @nodoc
class __$FridgeReportDomainCopyWithImpl<$Res>
    implements _$FridgeReportDomainCopyWith<$Res> {
  __$FridgeReportDomainCopyWithImpl(this._self, this._then);

  final _FridgeReportDomain _self;
  final $Res Function(_FridgeReportDomain) _then;

/// Create a copy of FridgeReportDomain
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fridgeId = null,Object? condition = null,Object? foodPercentage = null,Object? notes = freezed,Object? photoUrl = freezed,Object? epochTimestamp = freezed,Object? timestamp = freezed,}) {
  return _then(_FridgeReportDomain(
fridgeId: null == fridgeId ? _self.fridgeId : fridgeId // ignore: cast_nullable_to_non_nullable
as String,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as FridgeCondition,foodPercentage: null == foodPercentage ? _self.foodPercentage : foodPercentage // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,epochTimestamp: freezed == epochTimestamp ? _self.epochTimestamp : epochTimestamp // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FridgeDomain {

 String get id; String get name; bool get verified; FridgeLocationDomain get location; FridgeMaintainerDomain? get maintainer; String? get notes; String? get photoUrl;// ignore: invalid_annotation_target
@JsonKey(name: 'last_edited') String? get lastEdited;// Unix epoch timestamp as string
 FridgeReportDomain? get latestFridgeReport;
/// Create a copy of FridgeDomain
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FridgeDomainCopyWith<FridgeDomain> get copyWith => _$FridgeDomainCopyWithImpl<FridgeDomain>(this as FridgeDomain, _$identity);

  /// Serializes this FridgeDomain to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FridgeDomain&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.location, location) || other.location == location)&&(identical(other.maintainer, maintainer) || other.maintainer == maintainer)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.lastEdited, lastEdited) || other.lastEdited == lastEdited)&&(identical(other.latestFridgeReport, latestFridgeReport) || other.latestFridgeReport == latestFridgeReport));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,verified,location,maintainer,notes,photoUrl,lastEdited,latestFridgeReport);

@override
String toString() {
  return 'FridgeDomain(id: $id, name: $name, verified: $verified, location: $location, maintainer: $maintainer, notes: $notes, photoUrl: $photoUrl, lastEdited: $lastEdited, latestFridgeReport: $latestFridgeReport)';
}


}

/// @nodoc
abstract mixin class $FridgeDomainCopyWith<$Res>  {
  factory $FridgeDomainCopyWith(FridgeDomain value, $Res Function(FridgeDomain) _then) = _$FridgeDomainCopyWithImpl;
@useResult
$Res call({
 String id, String name, bool verified, FridgeLocationDomain location, FridgeMaintainerDomain? maintainer, String? notes, String? photoUrl,@JsonKey(name: 'last_edited') String? lastEdited, FridgeReportDomain? latestFridgeReport
});


$FridgeLocationDomainCopyWith<$Res> get location;$FridgeMaintainerDomainCopyWith<$Res>? get maintainer;$FridgeReportDomainCopyWith<$Res>? get latestFridgeReport;

}
/// @nodoc
class _$FridgeDomainCopyWithImpl<$Res>
    implements $FridgeDomainCopyWith<$Res> {
  _$FridgeDomainCopyWithImpl(this._self, this._then);

  final FridgeDomain _self;
  final $Res Function(FridgeDomain) _then;

/// Create a copy of FridgeDomain
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? verified = null,Object? location = null,Object? maintainer = freezed,Object? notes = freezed,Object? photoUrl = freezed,Object? lastEdited = freezed,Object? latestFridgeReport = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as FridgeLocationDomain,maintainer: freezed == maintainer ? _self.maintainer : maintainer // ignore: cast_nullable_to_non_nullable
as FridgeMaintainerDomain?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,lastEdited: freezed == lastEdited ? _self.lastEdited : lastEdited // ignore: cast_nullable_to_non_nullable
as String?,latestFridgeReport: freezed == latestFridgeReport ? _self.latestFridgeReport : latestFridgeReport // ignore: cast_nullable_to_non_nullable
as FridgeReportDomain?,
  ));
}
/// Create a copy of FridgeDomain
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FridgeLocationDomainCopyWith<$Res> get location {
  
  return $FridgeLocationDomainCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of FridgeDomain
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FridgeMaintainerDomainCopyWith<$Res>? get maintainer {
    if (_self.maintainer == null) {
    return null;
  }

  return $FridgeMaintainerDomainCopyWith<$Res>(_self.maintainer!, (value) {
    return _then(_self.copyWith(maintainer: value));
  });
}/// Create a copy of FridgeDomain
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FridgeReportDomainCopyWith<$Res>? get latestFridgeReport {
    if (_self.latestFridgeReport == null) {
    return null;
  }

  return $FridgeReportDomainCopyWith<$Res>(_self.latestFridgeReport!, (value) {
    return _then(_self.copyWith(latestFridgeReport: value));
  });
}
}


/// Adds pattern-matching-related methods to [FridgeDomain].
extension FridgeDomainPatterns on FridgeDomain {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FridgeDomain value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FridgeDomain() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FridgeDomain value)  $default,){
final _that = this;
switch (_that) {
case _FridgeDomain():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FridgeDomain value)?  $default,){
final _that = this;
switch (_that) {
case _FridgeDomain() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  bool verified,  FridgeLocationDomain location,  FridgeMaintainerDomain? maintainer,  String? notes,  String? photoUrl, @JsonKey(name: 'last_edited')  String? lastEdited,  FridgeReportDomain? latestFridgeReport)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FridgeDomain() when $default != null:
return $default(_that.id,_that.name,_that.verified,_that.location,_that.maintainer,_that.notes,_that.photoUrl,_that.lastEdited,_that.latestFridgeReport);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  bool verified,  FridgeLocationDomain location,  FridgeMaintainerDomain? maintainer,  String? notes,  String? photoUrl, @JsonKey(name: 'last_edited')  String? lastEdited,  FridgeReportDomain? latestFridgeReport)  $default,) {final _that = this;
switch (_that) {
case _FridgeDomain():
return $default(_that.id,_that.name,_that.verified,_that.location,_that.maintainer,_that.notes,_that.photoUrl,_that.lastEdited,_that.latestFridgeReport);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  bool verified,  FridgeLocationDomain location,  FridgeMaintainerDomain? maintainer,  String? notes,  String? photoUrl, @JsonKey(name: 'last_edited')  String? lastEdited,  FridgeReportDomain? latestFridgeReport)?  $default,) {final _that = this;
switch (_that) {
case _FridgeDomain() when $default != null:
return $default(_that.id,_that.name,_that.verified,_that.location,_that.maintainer,_that.notes,_that.photoUrl,_that.lastEdited,_that.latestFridgeReport);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FridgeDomain extends FridgeDomain {
  const _FridgeDomain({required this.id, required this.name, this.verified = false, required this.location, this.maintainer, this.notes, this.photoUrl, @JsonKey(name: 'last_edited') this.lastEdited, this.latestFridgeReport}): super._();
  factory _FridgeDomain.fromJson(Map<String, dynamic> json) => _$FridgeDomainFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  bool verified;
@override final  FridgeLocationDomain location;
@override final  FridgeMaintainerDomain? maintainer;
@override final  String? notes;
@override final  String? photoUrl;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'last_edited') final  String? lastEdited;
// Unix epoch timestamp as string
@override final  FridgeReportDomain? latestFridgeReport;

/// Create a copy of FridgeDomain
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FridgeDomainCopyWith<_FridgeDomain> get copyWith => __$FridgeDomainCopyWithImpl<_FridgeDomain>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FridgeDomainToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FridgeDomain&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.location, location) || other.location == location)&&(identical(other.maintainer, maintainer) || other.maintainer == maintainer)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.lastEdited, lastEdited) || other.lastEdited == lastEdited)&&(identical(other.latestFridgeReport, latestFridgeReport) || other.latestFridgeReport == latestFridgeReport));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,verified,location,maintainer,notes,photoUrl,lastEdited,latestFridgeReport);

@override
String toString() {
  return 'FridgeDomain(id: $id, name: $name, verified: $verified, location: $location, maintainer: $maintainer, notes: $notes, photoUrl: $photoUrl, lastEdited: $lastEdited, latestFridgeReport: $latestFridgeReport)';
}


}

/// @nodoc
abstract mixin class _$FridgeDomainCopyWith<$Res> implements $FridgeDomainCopyWith<$Res> {
  factory _$FridgeDomainCopyWith(_FridgeDomain value, $Res Function(_FridgeDomain) _then) = __$FridgeDomainCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, bool verified, FridgeLocationDomain location, FridgeMaintainerDomain? maintainer, String? notes, String? photoUrl,@JsonKey(name: 'last_edited') String? lastEdited, FridgeReportDomain? latestFridgeReport
});


@override $FridgeLocationDomainCopyWith<$Res> get location;@override $FridgeMaintainerDomainCopyWith<$Res>? get maintainer;@override $FridgeReportDomainCopyWith<$Res>? get latestFridgeReport;

}
/// @nodoc
class __$FridgeDomainCopyWithImpl<$Res>
    implements _$FridgeDomainCopyWith<$Res> {
  __$FridgeDomainCopyWithImpl(this._self, this._then);

  final _FridgeDomain _self;
  final $Res Function(_FridgeDomain) _then;

/// Create a copy of FridgeDomain
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? verified = null,Object? location = null,Object? maintainer = freezed,Object? notes = freezed,Object? photoUrl = freezed,Object? lastEdited = freezed,Object? latestFridgeReport = freezed,}) {
  return _then(_FridgeDomain(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as FridgeLocationDomain,maintainer: freezed == maintainer ? _self.maintainer : maintainer // ignore: cast_nullable_to_non_nullable
as FridgeMaintainerDomain?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,lastEdited: freezed == lastEdited ? _self.lastEdited : lastEdited // ignore: cast_nullable_to_non_nullable
as String?,latestFridgeReport: freezed == latestFridgeReport ? _self.latestFridgeReport : latestFridgeReport // ignore: cast_nullable_to_non_nullable
as FridgeReportDomain?,
  ));
}

/// Create a copy of FridgeDomain
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FridgeLocationDomainCopyWith<$Res> get location {
  
  return $FridgeLocationDomainCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of FridgeDomain
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FridgeMaintainerDomainCopyWith<$Res>? get maintainer {
    if (_self.maintainer == null) {
    return null;
  }

  return $FridgeMaintainerDomainCopyWith<$Res>(_self.maintainer!, (value) {
    return _then(_self.copyWith(maintainer: value));
  });
}/// Create a copy of FridgeDomain
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FridgeReportDomainCopyWith<$Res>? get latestFridgeReport {
    if (_self.latestFridgeReport == null) {
    return null;
  }

  return $FridgeReportDomainCopyWith<$Res>(_self.latestFridgeReport!, (value) {
    return _then(_self.copyWith(latestFridgeReport: value));
  });
}
}

// dart format on
