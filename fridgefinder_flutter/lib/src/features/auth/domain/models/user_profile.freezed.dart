// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserSettings {

 bool get notificationsEnabled; NotificationFrequency get notificationFrequency; bool get geofencingEnabled;
/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<UserSettings> get copyWith => _$UserSettingsCopyWithImpl<UserSettings>(this as UserSettings, _$identity);

  /// Serializes this UserSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSettings&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.notificationFrequency, notificationFrequency) || other.notificationFrequency == notificationFrequency)&&(identical(other.geofencingEnabled, geofencingEnabled) || other.geofencingEnabled == geofencingEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,notificationsEnabled,notificationFrequency,geofencingEnabled);

@override
String toString() {
  return 'UserSettings(notificationsEnabled: $notificationsEnabled, notificationFrequency: $notificationFrequency, geofencingEnabled: $geofencingEnabled)';
}


}

/// @nodoc
abstract mixin class $UserSettingsCopyWith<$Res>  {
  factory $UserSettingsCopyWith(UserSettings value, $Res Function(UserSettings) _then) = _$UserSettingsCopyWithImpl;
@useResult
$Res call({
 bool notificationsEnabled, NotificationFrequency notificationFrequency, bool geofencingEnabled
});




}
/// @nodoc
class _$UserSettingsCopyWithImpl<$Res>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._self, this._then);

  final UserSettings _self;
  final $Res Function(UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? notificationsEnabled = null,Object? notificationFrequency = null,Object? geofencingEnabled = null,}) {
  return _then(_self.copyWith(
notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,notificationFrequency: null == notificationFrequency ? _self.notificationFrequency : notificationFrequency // ignore: cast_nullable_to_non_nullable
as NotificationFrequency,geofencingEnabled: null == geofencingEnabled ? _self.geofencingEnabled : geofencingEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserSettings].
extension UserSettingsPatterns on UserSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSettings value)  $default,){
final _that = this;
switch (_that) {
case _UserSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSettings value)?  $default,){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool notificationsEnabled,  NotificationFrequency notificationFrequency,  bool geofencingEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.notificationsEnabled,_that.notificationFrequency,_that.geofencingEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool notificationsEnabled,  NotificationFrequency notificationFrequency,  bool geofencingEnabled)  $default,) {final _that = this;
switch (_that) {
case _UserSettings():
return $default(_that.notificationsEnabled,_that.notificationFrequency,_that.geofencingEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool notificationsEnabled,  NotificationFrequency notificationFrequency,  bool geofencingEnabled)?  $default,) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.notificationsEnabled,_that.notificationFrequency,_that.geofencingEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserSettings extends UserSettings {
  const _UserSettings({this.notificationsEnabled = true, this.notificationFrequency = NotificationFrequency.immediate, this.geofencingEnabled = false}): super._();
  factory _UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);

@override@JsonKey() final  bool notificationsEnabled;
@override@JsonKey() final  NotificationFrequency notificationFrequency;
@override@JsonKey() final  bool geofencingEnabled;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSettingsCopyWith<_UserSettings> get copyWith => __$UserSettingsCopyWithImpl<_UserSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSettings&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.notificationFrequency, notificationFrequency) || other.notificationFrequency == notificationFrequency)&&(identical(other.geofencingEnabled, geofencingEnabled) || other.geofencingEnabled == geofencingEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,notificationsEnabled,notificationFrequency,geofencingEnabled);

@override
String toString() {
  return 'UserSettings(notificationsEnabled: $notificationsEnabled, notificationFrequency: $notificationFrequency, geofencingEnabled: $geofencingEnabled)';
}


}

/// @nodoc
abstract mixin class _$UserSettingsCopyWith<$Res> implements $UserSettingsCopyWith<$Res> {
  factory _$UserSettingsCopyWith(_UserSettings value, $Res Function(_UserSettings) _then) = __$UserSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool notificationsEnabled, NotificationFrequency notificationFrequency, bool geofencingEnabled
});




}
/// @nodoc
class __$UserSettingsCopyWithImpl<$Res>
    implements _$UserSettingsCopyWith<$Res> {
  __$UserSettingsCopyWithImpl(this._self, this._then);

  final _UserSettings _self;
  final $Res Function(_UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? notificationsEnabled = null,Object? notificationFrequency = null,Object? geofencingEnabled = null,}) {
  return _then(_UserSettings(
notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,notificationFrequency: null == notificationFrequency ? _self.notificationFrequency : notificationFrequency // ignore: cast_nullable_to_non_nullable
as NotificationFrequency,geofencingEnabled: null == geofencingEnabled ? _self.geofencingEnabled : geofencingEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$UserProfile {

 String get userId; String? get email; String? get phoneNumber; String get username; bool get isVolunteer; String? get zipCode; int get points; String? get fcmToken; Map<String, String>? get fcmTokens; UserSettings get settings; bool get newsletterOptIn; DateTime get createdAt; DateTime? get lastLoginAt;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.username, username) || other.username == username)&&(identical(other.isVolunteer, isVolunteer) || other.isVolunteer == isVolunteer)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.points, points) || other.points == points)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&const DeepCollectionEquality().equals(other.fcmTokens, fcmTokens)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.newsletterOptIn, newsletterOptIn) || other.newsletterOptIn == newsletterOptIn)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,email,phoneNumber,username,isVolunteer,zipCode,points,fcmToken,const DeepCollectionEquality().hash(fcmTokens),settings,newsletterOptIn,createdAt,lastLoginAt);

@override
String toString() {
  return 'UserProfile(userId: $userId, email: $email, phoneNumber: $phoneNumber, username: $username, isVolunteer: $isVolunteer, zipCode: $zipCode, points: $points, fcmToken: $fcmToken, fcmTokens: $fcmTokens, settings: $settings, newsletterOptIn: $newsletterOptIn, createdAt: $createdAt, lastLoginAt: $lastLoginAt)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String userId, String? email, String? phoneNumber, String username, bool isVolunteer, String? zipCode, int points, String? fcmToken, Map<String, String>? fcmTokens, UserSettings settings, bool newsletterOptIn, DateTime createdAt, DateTime? lastLoginAt
});


$UserSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? email = freezed,Object? phoneNumber = freezed,Object? username = null,Object? isVolunteer = null,Object? zipCode = freezed,Object? points = null,Object? fcmToken = freezed,Object? fcmTokens = freezed,Object? settings = null,Object? newsletterOptIn = null,Object? createdAt = null,Object? lastLoginAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,isVolunteer: null == isVolunteer ? _self.isVolunteer : isVolunteer // ignore: cast_nullable_to_non_nullable
as bool,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,fcmTokens: freezed == fcmTokens ? _self.fcmTokens : fcmTokens // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as UserSettings,newsletterOptIn: null == newsletterOptIn ? _self.newsletterOptIn : newsletterOptIn // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<$Res> get settings {
  
  return $UserSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String? email,  String? phoneNumber,  String username,  bool isVolunteer,  String? zipCode,  int points,  String? fcmToken,  Map<String, String>? fcmTokens,  UserSettings settings,  bool newsletterOptIn,  DateTime createdAt,  DateTime? lastLoginAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.userId,_that.email,_that.phoneNumber,_that.username,_that.isVolunteer,_that.zipCode,_that.points,_that.fcmToken,_that.fcmTokens,_that.settings,_that.newsletterOptIn,_that.createdAt,_that.lastLoginAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String? email,  String? phoneNumber,  String username,  bool isVolunteer,  String? zipCode,  int points,  String? fcmToken,  Map<String, String>? fcmTokens,  UserSettings settings,  bool newsletterOptIn,  DateTime createdAt,  DateTime? lastLoginAt)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.userId,_that.email,_that.phoneNumber,_that.username,_that.isVolunteer,_that.zipCode,_that.points,_that.fcmToken,_that.fcmTokens,_that.settings,_that.newsletterOptIn,_that.createdAt,_that.lastLoginAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String? email,  String? phoneNumber,  String username,  bool isVolunteer,  String? zipCode,  int points,  String? fcmToken,  Map<String, String>? fcmTokens,  UserSettings settings,  bool newsletterOptIn,  DateTime createdAt,  DateTime? lastLoginAt)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.userId,_that.email,_that.phoneNumber,_that.username,_that.isVolunteer,_that.zipCode,_that.points,_that.fcmToken,_that.fcmTokens,_that.settings,_that.newsletterOptIn,_that.createdAt,_that.lastLoginAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile extends UserProfile {
  const _UserProfile({required this.userId, this.email, this.phoneNumber, required this.username, required this.isVolunteer, this.zipCode, this.points = 0, this.fcmToken, final  Map<String, String>? fcmTokens, this.settings = const UserSettings(), this.newsletterOptIn = false, required this.createdAt, this.lastLoginAt}): _fcmTokens = fcmTokens,super._();
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  String userId;
@override final  String? email;
@override final  String? phoneNumber;
@override final  String username;
@override final  bool isVolunteer;
@override final  String? zipCode;
@override@JsonKey() final  int points;
@override final  String? fcmToken;
 final  Map<String, String>? _fcmTokens;
@override Map<String, String>? get fcmTokens {
  final value = _fcmTokens;
  if (value == null) return null;
  if (_fcmTokens is EqualUnmodifiableMapView) return _fcmTokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  UserSettings settings;
@override@JsonKey() final  bool newsletterOptIn;
@override final  DateTime createdAt;
@override final  DateTime? lastLoginAt;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.username, username) || other.username == username)&&(identical(other.isVolunteer, isVolunteer) || other.isVolunteer == isVolunteer)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.points, points) || other.points == points)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&const DeepCollectionEquality().equals(other._fcmTokens, _fcmTokens)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.newsletterOptIn, newsletterOptIn) || other.newsletterOptIn == newsletterOptIn)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,email,phoneNumber,username,isVolunteer,zipCode,points,fcmToken,const DeepCollectionEquality().hash(_fcmTokens),settings,newsletterOptIn,createdAt,lastLoginAt);

@override
String toString() {
  return 'UserProfile(userId: $userId, email: $email, phoneNumber: $phoneNumber, username: $username, isVolunteer: $isVolunteer, zipCode: $zipCode, points: $points, fcmToken: $fcmToken, fcmTokens: $fcmTokens, settings: $settings, newsletterOptIn: $newsletterOptIn, createdAt: $createdAt, lastLoginAt: $lastLoginAt)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String userId, String? email, String? phoneNumber, String username, bool isVolunteer, String? zipCode, int points, String? fcmToken, Map<String, String>? fcmTokens, UserSettings settings, bool newsletterOptIn, DateTime createdAt, DateTime? lastLoginAt
});


@override $UserSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? email = freezed,Object? phoneNumber = freezed,Object? username = null,Object? isVolunteer = null,Object? zipCode = freezed,Object? points = null,Object? fcmToken = freezed,Object? fcmTokens = freezed,Object? settings = null,Object? newsletterOptIn = null,Object? createdAt = null,Object? lastLoginAt = freezed,}) {
  return _then(_UserProfile(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,isVolunteer: null == isVolunteer ? _self.isVolunteer : isVolunteer // ignore: cast_nullable_to_non_nullable
as bool,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,fcmTokens: freezed == fcmTokens ? _self._fcmTokens : fcmTokens // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as UserSettings,newsletterOptIn: null == newsletterOptIn ? _self.newsletterOptIn : newsletterOptIn // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<$Res> get settings {
  
  return $UserSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}

// dart format on
