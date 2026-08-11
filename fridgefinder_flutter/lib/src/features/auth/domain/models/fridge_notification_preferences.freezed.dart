// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fridge_notification_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FridgeNotificationPreferences {

 String get fridgeId; DateTime? get updatedAt; NotificationPreferences get notificationPreferences;
/// Create a copy of FridgeNotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FridgeNotificationPreferencesCopyWith<FridgeNotificationPreferences> get copyWith => _$FridgeNotificationPreferencesCopyWithImpl<FridgeNotificationPreferences>(this as FridgeNotificationPreferences, _$identity);

  /// Serializes this FridgeNotificationPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FridgeNotificationPreferences&&(identical(other.fridgeId, fridgeId) || other.fridgeId == fridgeId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.notificationPreferences, notificationPreferences) || other.notificationPreferences == notificationPreferences));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fridgeId,updatedAt,notificationPreferences);

@override
String toString() {
  return 'FridgeNotificationPreferences(fridgeId: $fridgeId, updatedAt: $updatedAt, notificationPreferences: $notificationPreferences)';
}


}

/// @nodoc
abstract mixin class $FridgeNotificationPreferencesCopyWith<$Res>  {
  factory $FridgeNotificationPreferencesCopyWith(FridgeNotificationPreferences value, $Res Function(FridgeNotificationPreferences) _then) = _$FridgeNotificationPreferencesCopyWithImpl;
@useResult
$Res call({
 String fridgeId, DateTime? updatedAt, NotificationPreferences notificationPreferences
});


$NotificationPreferencesCopyWith<$Res> get notificationPreferences;

}
/// @nodoc
class _$FridgeNotificationPreferencesCopyWithImpl<$Res>
    implements $FridgeNotificationPreferencesCopyWith<$Res> {
  _$FridgeNotificationPreferencesCopyWithImpl(this._self, this._then);

  final FridgeNotificationPreferences _self;
  final $Res Function(FridgeNotificationPreferences) _then;

/// Create a copy of FridgeNotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fridgeId = null,Object? updatedAt = freezed,Object? notificationPreferences = null,}) {
  return _then(_self.copyWith(
fridgeId: null == fridgeId ? _self.fridgeId : fridgeId // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notificationPreferences: null == notificationPreferences ? _self.notificationPreferences : notificationPreferences // ignore: cast_nullable_to_non_nullable
as NotificationPreferences,
  ));
}
/// Create a copy of FridgeNotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<$Res> get notificationPreferences {
  
  return $NotificationPreferencesCopyWith<$Res>(_self.notificationPreferences, (value) {
    return _then(_self.copyWith(notificationPreferences: value));
  });
}
}


/// Adds pattern-matching-related methods to [FridgeNotificationPreferences].
extension FridgeNotificationPreferencesPatterns on FridgeNotificationPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FridgeNotificationPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FridgeNotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FridgeNotificationPreferences value)  $default,){
final _that = this;
switch (_that) {
case _FridgeNotificationPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FridgeNotificationPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _FridgeNotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fridgeId,  DateTime? updatedAt,  NotificationPreferences notificationPreferences)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FridgeNotificationPreferences() when $default != null:
return $default(_that.fridgeId,_that.updatedAt,_that.notificationPreferences);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fridgeId,  DateTime? updatedAt,  NotificationPreferences notificationPreferences)  $default,) {final _that = this;
switch (_that) {
case _FridgeNotificationPreferences():
return $default(_that.fridgeId,_that.updatedAt,_that.notificationPreferences);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fridgeId,  DateTime? updatedAt,  NotificationPreferences notificationPreferences)?  $default,) {final _that = this;
switch (_that) {
case _FridgeNotificationPreferences() when $default != null:
return $default(_that.fridgeId,_that.updatedAt,_that.notificationPreferences);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FridgeNotificationPreferences extends FridgeNotificationPreferences {
  const _FridgeNotificationPreferences({required this.fridgeId, this.updatedAt, this.notificationPreferences = const NotificationPreferences()}): super._();
  factory _FridgeNotificationPreferences.fromJson(Map<String, dynamic> json) => _$FridgeNotificationPreferencesFromJson(json);

@override final  String fridgeId;
@override final  DateTime? updatedAt;
@override@JsonKey() final  NotificationPreferences notificationPreferences;

/// Create a copy of FridgeNotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FridgeNotificationPreferencesCopyWith<_FridgeNotificationPreferences> get copyWith => __$FridgeNotificationPreferencesCopyWithImpl<_FridgeNotificationPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FridgeNotificationPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FridgeNotificationPreferences&&(identical(other.fridgeId, fridgeId) || other.fridgeId == fridgeId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.notificationPreferences, notificationPreferences) || other.notificationPreferences == notificationPreferences));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fridgeId,updatedAt,notificationPreferences);

@override
String toString() {
  return 'FridgeNotificationPreferences(fridgeId: $fridgeId, updatedAt: $updatedAt, notificationPreferences: $notificationPreferences)';
}


}

/// @nodoc
abstract mixin class _$FridgeNotificationPreferencesCopyWith<$Res> implements $FridgeNotificationPreferencesCopyWith<$Res> {
  factory _$FridgeNotificationPreferencesCopyWith(_FridgeNotificationPreferences value, $Res Function(_FridgeNotificationPreferences) _then) = __$FridgeNotificationPreferencesCopyWithImpl;
@override @useResult
$Res call({
 String fridgeId, DateTime? updatedAt, NotificationPreferences notificationPreferences
});


@override $NotificationPreferencesCopyWith<$Res> get notificationPreferences;

}
/// @nodoc
class __$FridgeNotificationPreferencesCopyWithImpl<$Res>
    implements _$FridgeNotificationPreferencesCopyWith<$Res> {
  __$FridgeNotificationPreferencesCopyWithImpl(this._self, this._then);

  final _FridgeNotificationPreferences _self;
  final $Res Function(_FridgeNotificationPreferences) _then;

/// Create a copy of FridgeNotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fridgeId = null,Object? updatedAt = freezed,Object? notificationPreferences = null,}) {
  return _then(_FridgeNotificationPreferences(
fridgeId: null == fridgeId ? _self.fridgeId : fridgeId // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notificationPreferences: null == notificationPreferences ? _self.notificationPreferences : notificationPreferences // ignore: cast_nullable_to_non_nullable
as NotificationPreferences,
  ));
}

/// Create a copy of FridgeNotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<$Res> get notificationPreferences {
  
  return $NotificationPreferencesCopyWith<$Res>(_self.notificationPreferences, (value) {
    return _then(_self.copyWith(notificationPreferences: value));
  });
}
}


/// @nodoc
mixin _$NotificationPreferences {

 ContactTypePreferences get contactTypePreferences;
/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<NotificationPreferences> get copyWith => _$NotificationPreferencesCopyWithImpl<NotificationPreferences>(this as NotificationPreferences, _$identity);

  /// Serializes this NotificationPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPreferences&&(identical(other.contactTypePreferences, contactTypePreferences) || other.contactTypePreferences == contactTypePreferences));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contactTypePreferences);

@override
String toString() {
  return 'NotificationPreferences(contactTypePreferences: $contactTypePreferences)';
}


}

/// @nodoc
abstract mixin class $NotificationPreferencesCopyWith<$Res>  {
  factory $NotificationPreferencesCopyWith(NotificationPreferences value, $Res Function(NotificationPreferences) _then) = _$NotificationPreferencesCopyWithImpl;
@useResult
$Res call({
 ContactTypePreferences contactTypePreferences
});


$ContactTypePreferencesCopyWith<$Res> get contactTypePreferences;

}
/// @nodoc
class _$NotificationPreferencesCopyWithImpl<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  _$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final NotificationPreferences _self;
  final $Res Function(NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contactTypePreferences = null,}) {
  return _then(_self.copyWith(
contactTypePreferences: null == contactTypePreferences ? _self.contactTypePreferences : contactTypePreferences // ignore: cast_nullable_to_non_nullable
as ContactTypePreferences,
  ));
}
/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactTypePreferencesCopyWith<$Res> get contactTypePreferences {
  
  return $ContactTypePreferencesCopyWith<$Res>(_self.contactTypePreferences, (value) {
    return _then(_self.copyWith(contactTypePreferences: value));
  });
}
}


/// Adds pattern-matching-related methods to [NotificationPreferences].
extension NotificationPreferencesPatterns on NotificationPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPreferences value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ContactTypePreferences contactTypePreferences)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.contactTypePreferences);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ContactTypePreferences contactTypePreferences)  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences():
return $default(_that.contactTypePreferences);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ContactTypePreferences contactTypePreferences)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.contactTypePreferences);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPreferences extends NotificationPreferences {
  const _NotificationPreferences({this.contactTypePreferences = const ContactTypePreferences()}): super._();
  factory _NotificationPreferences.fromJson(Map<String, dynamic> json) => _$NotificationPreferencesFromJson(json);

@override@JsonKey() final  ContactTypePreferences contactTypePreferences;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPreferencesCopyWith<_NotificationPreferences> get copyWith => __$NotificationPreferencesCopyWithImpl<_NotificationPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPreferences&&(identical(other.contactTypePreferences, contactTypePreferences) || other.contactTypePreferences == contactTypePreferences));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contactTypePreferences);

@override
String toString() {
  return 'NotificationPreferences(contactTypePreferences: $contactTypePreferences)';
}


}

/// @nodoc
abstract mixin class _$NotificationPreferencesCopyWith<$Res> implements $NotificationPreferencesCopyWith<$Res> {
  factory _$NotificationPreferencesCopyWith(_NotificationPreferences value, $Res Function(_NotificationPreferences) _then) = __$NotificationPreferencesCopyWithImpl;
@override @useResult
$Res call({
 ContactTypePreferences contactTypePreferences
});


@override $ContactTypePreferencesCopyWith<$Res> get contactTypePreferences;

}
/// @nodoc
class __$NotificationPreferencesCopyWithImpl<$Res>
    implements _$NotificationPreferencesCopyWith<$Res> {
  __$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final _NotificationPreferences _self;
  final $Res Function(_NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contactTypePreferences = null,}) {
  return _then(_NotificationPreferences(
contactTypePreferences: null == contactTypePreferences ? _self.contactTypePreferences : contactTypePreferences // ignore: cast_nullable_to_non_nullable
as ContactTypePreferences,
  ));
}

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactTypePreferencesCopyWith<$Res> get contactTypePreferences {
  
  return $ContactTypePreferencesCopyWith<$Res>(_self.contactTypePreferences, (value) {
    return _then(_self.copyWith(contactTypePreferences: value));
  });
}
}


/// @nodoc
mixin _$ContactTypePreferences {

 FridgeNotificationFlags get email; FridgeNotificationFlags get device;
/// Create a copy of ContactTypePreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactTypePreferencesCopyWith<ContactTypePreferences> get copyWith => _$ContactTypePreferencesCopyWithImpl<ContactTypePreferences>(this as ContactTypePreferences, _$identity);

  /// Serializes this ContactTypePreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactTypePreferences&&(identical(other.email, email) || other.email == email)&&(identical(other.device, device) || other.device == device));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,device);

@override
String toString() {
  return 'ContactTypePreferences(email: $email, device: $device)';
}


}

/// @nodoc
abstract mixin class $ContactTypePreferencesCopyWith<$Res>  {
  factory $ContactTypePreferencesCopyWith(ContactTypePreferences value, $Res Function(ContactTypePreferences) _then) = _$ContactTypePreferencesCopyWithImpl;
@useResult
$Res call({
 FridgeNotificationFlags email, FridgeNotificationFlags device
});


$FridgeNotificationFlagsCopyWith<$Res> get email;$FridgeNotificationFlagsCopyWith<$Res> get device;

}
/// @nodoc
class _$ContactTypePreferencesCopyWithImpl<$Res>
    implements $ContactTypePreferencesCopyWith<$Res> {
  _$ContactTypePreferencesCopyWithImpl(this._self, this._then);

  final ContactTypePreferences _self;
  final $Res Function(ContactTypePreferences) _then;

/// Create a copy of ContactTypePreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? device = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as FridgeNotificationFlags,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as FridgeNotificationFlags,
  ));
}
/// Create a copy of ContactTypePreferences
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FridgeNotificationFlagsCopyWith<$Res> get email {
  
  return $FridgeNotificationFlagsCopyWith<$Res>(_self.email, (value) {
    return _then(_self.copyWith(email: value));
  });
}/// Create a copy of ContactTypePreferences
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FridgeNotificationFlagsCopyWith<$Res> get device {
  
  return $FridgeNotificationFlagsCopyWith<$Res>(_self.device, (value) {
    return _then(_self.copyWith(device: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContactTypePreferences].
extension ContactTypePreferencesPatterns on ContactTypePreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactTypePreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactTypePreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactTypePreferences value)  $default,){
final _that = this;
switch (_that) {
case _ContactTypePreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactTypePreferences value)?  $default,){
final _that = this;
switch (_that) {
case _ContactTypePreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FridgeNotificationFlags email,  FridgeNotificationFlags device)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactTypePreferences() when $default != null:
return $default(_that.email,_that.device);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FridgeNotificationFlags email,  FridgeNotificationFlags device)  $default,) {final _that = this;
switch (_that) {
case _ContactTypePreferences():
return $default(_that.email,_that.device);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FridgeNotificationFlags email,  FridgeNotificationFlags device)?  $default,) {final _that = this;
switch (_that) {
case _ContactTypePreferences() when $default != null:
return $default(_that.email,_that.device);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContactTypePreferences extends ContactTypePreferences {
  const _ContactTypePreferences({this.email = const FridgeNotificationFlags(), this.device = const FridgeNotificationFlags()}): super._();
  factory _ContactTypePreferences.fromJson(Map<String, dynamic> json) => _$ContactTypePreferencesFromJson(json);

@override@JsonKey() final  FridgeNotificationFlags email;
@override@JsonKey() final  FridgeNotificationFlags device;

/// Create a copy of ContactTypePreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactTypePreferencesCopyWith<_ContactTypePreferences> get copyWith => __$ContactTypePreferencesCopyWithImpl<_ContactTypePreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactTypePreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactTypePreferences&&(identical(other.email, email) || other.email == email)&&(identical(other.device, device) || other.device == device));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,device);

@override
String toString() {
  return 'ContactTypePreferences(email: $email, device: $device)';
}


}

/// @nodoc
abstract mixin class _$ContactTypePreferencesCopyWith<$Res> implements $ContactTypePreferencesCopyWith<$Res> {
  factory _$ContactTypePreferencesCopyWith(_ContactTypePreferences value, $Res Function(_ContactTypePreferences) _then) = __$ContactTypePreferencesCopyWithImpl;
@override @useResult
$Res call({
 FridgeNotificationFlags email, FridgeNotificationFlags device
});


@override $FridgeNotificationFlagsCopyWith<$Res> get email;@override $FridgeNotificationFlagsCopyWith<$Res> get device;

}
/// @nodoc
class __$ContactTypePreferencesCopyWithImpl<$Res>
    implements _$ContactTypePreferencesCopyWith<$Res> {
  __$ContactTypePreferencesCopyWithImpl(this._self, this._then);

  final _ContactTypePreferences _self;
  final $Res Function(_ContactTypePreferences) _then;

/// Create a copy of ContactTypePreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? device = null,}) {
  return _then(_ContactTypePreferences(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as FridgeNotificationFlags,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as FridgeNotificationFlags,
  ));
}

/// Create a copy of ContactTypePreferences
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FridgeNotificationFlagsCopyWith<$Res> get email {
  
  return $FridgeNotificationFlagsCopyWith<$Res>(_self.email, (value) {
    return _then(_self.copyWith(email: value));
  });
}/// Create a copy of ContactTypePreferences
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FridgeNotificationFlagsCopyWith<$Res> get device {
  
  return $FridgeNotificationFlagsCopyWith<$Res>(_self.device, (value) {
    return _then(_self.copyWith(device: value));
  });
}
}


/// @nodoc
mixin _$FridgeNotificationFlags {

 bool get good; bool get dirty; bool get outOfOrder; bool get notAtLocation; bool get ghost; bool get noFood; bool get hasFood;
/// Create a copy of FridgeNotificationFlags
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FridgeNotificationFlagsCopyWith<FridgeNotificationFlags> get copyWith => _$FridgeNotificationFlagsCopyWithImpl<FridgeNotificationFlags>(this as FridgeNotificationFlags, _$identity);

  /// Serializes this FridgeNotificationFlags to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FridgeNotificationFlags&&(identical(other.good, good) || other.good == good)&&(identical(other.dirty, dirty) || other.dirty == dirty)&&(identical(other.outOfOrder, outOfOrder) || other.outOfOrder == outOfOrder)&&(identical(other.notAtLocation, notAtLocation) || other.notAtLocation == notAtLocation)&&(identical(other.ghost, ghost) || other.ghost == ghost)&&(identical(other.noFood, noFood) || other.noFood == noFood)&&(identical(other.hasFood, hasFood) || other.hasFood == hasFood));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,good,dirty,outOfOrder,notAtLocation,ghost,noFood,hasFood);

@override
String toString() {
  return 'FridgeNotificationFlags(good: $good, dirty: $dirty, outOfOrder: $outOfOrder, notAtLocation: $notAtLocation, ghost: $ghost, noFood: $noFood, hasFood: $hasFood)';
}


}

/// @nodoc
abstract mixin class $FridgeNotificationFlagsCopyWith<$Res>  {
  factory $FridgeNotificationFlagsCopyWith(FridgeNotificationFlags value, $Res Function(FridgeNotificationFlags) _then) = _$FridgeNotificationFlagsCopyWithImpl;
@useResult
$Res call({
 bool good, bool dirty, bool outOfOrder, bool notAtLocation, bool ghost, bool noFood, bool hasFood
});




}
/// @nodoc
class _$FridgeNotificationFlagsCopyWithImpl<$Res>
    implements $FridgeNotificationFlagsCopyWith<$Res> {
  _$FridgeNotificationFlagsCopyWithImpl(this._self, this._then);

  final FridgeNotificationFlags _self;
  final $Res Function(FridgeNotificationFlags) _then;

/// Create a copy of FridgeNotificationFlags
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? good = null,Object? dirty = null,Object? outOfOrder = null,Object? notAtLocation = null,Object? ghost = null,Object? noFood = null,Object? hasFood = null,}) {
  return _then(_self.copyWith(
good: null == good ? _self.good : good // ignore: cast_nullable_to_non_nullable
as bool,dirty: null == dirty ? _self.dirty : dirty // ignore: cast_nullable_to_non_nullable
as bool,outOfOrder: null == outOfOrder ? _self.outOfOrder : outOfOrder // ignore: cast_nullable_to_non_nullable
as bool,notAtLocation: null == notAtLocation ? _self.notAtLocation : notAtLocation // ignore: cast_nullable_to_non_nullable
as bool,ghost: null == ghost ? _self.ghost : ghost // ignore: cast_nullable_to_non_nullable
as bool,noFood: null == noFood ? _self.noFood : noFood // ignore: cast_nullable_to_non_nullable
as bool,hasFood: null == hasFood ? _self.hasFood : hasFood // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FridgeNotificationFlags].
extension FridgeNotificationFlagsPatterns on FridgeNotificationFlags {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FridgeNotificationFlags value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FridgeNotificationFlags() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FridgeNotificationFlags value)  $default,){
final _that = this;
switch (_that) {
case _FridgeNotificationFlags():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FridgeNotificationFlags value)?  $default,){
final _that = this;
switch (_that) {
case _FridgeNotificationFlags() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool good,  bool dirty,  bool outOfOrder,  bool notAtLocation,  bool ghost,  bool noFood,  bool hasFood)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FridgeNotificationFlags() when $default != null:
return $default(_that.good,_that.dirty,_that.outOfOrder,_that.notAtLocation,_that.ghost,_that.noFood,_that.hasFood);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool good,  bool dirty,  bool outOfOrder,  bool notAtLocation,  bool ghost,  bool noFood,  bool hasFood)  $default,) {final _that = this;
switch (_that) {
case _FridgeNotificationFlags():
return $default(_that.good,_that.dirty,_that.outOfOrder,_that.notAtLocation,_that.ghost,_that.noFood,_that.hasFood);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool good,  bool dirty,  bool outOfOrder,  bool notAtLocation,  bool ghost,  bool noFood,  bool hasFood)?  $default,) {final _that = this;
switch (_that) {
case _FridgeNotificationFlags() when $default != null:
return $default(_that.good,_that.dirty,_that.outOfOrder,_that.notAtLocation,_that.ghost,_that.noFood,_that.hasFood);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FridgeNotificationFlags extends FridgeNotificationFlags {
  const _FridgeNotificationFlags({this.good = true, this.dirty = false, this.outOfOrder = false, this.notAtLocation = true, this.ghost = true, this.noFood = false, this.hasFood = false}): super._();
  factory _FridgeNotificationFlags.fromJson(Map<String, dynamic> json) => _$FridgeNotificationFlagsFromJson(json);

@override@JsonKey() final  bool good;
@override@JsonKey() final  bool dirty;
@override@JsonKey() final  bool outOfOrder;
@override@JsonKey() final  bool notAtLocation;
@override@JsonKey() final  bool ghost;
@override@JsonKey() final  bool noFood;
@override@JsonKey() final  bool hasFood;

/// Create a copy of FridgeNotificationFlags
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FridgeNotificationFlagsCopyWith<_FridgeNotificationFlags> get copyWith => __$FridgeNotificationFlagsCopyWithImpl<_FridgeNotificationFlags>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FridgeNotificationFlagsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FridgeNotificationFlags&&(identical(other.good, good) || other.good == good)&&(identical(other.dirty, dirty) || other.dirty == dirty)&&(identical(other.outOfOrder, outOfOrder) || other.outOfOrder == outOfOrder)&&(identical(other.notAtLocation, notAtLocation) || other.notAtLocation == notAtLocation)&&(identical(other.ghost, ghost) || other.ghost == ghost)&&(identical(other.noFood, noFood) || other.noFood == noFood)&&(identical(other.hasFood, hasFood) || other.hasFood == hasFood));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,good,dirty,outOfOrder,notAtLocation,ghost,noFood,hasFood);

@override
String toString() {
  return 'FridgeNotificationFlags(good: $good, dirty: $dirty, outOfOrder: $outOfOrder, notAtLocation: $notAtLocation, ghost: $ghost, noFood: $noFood, hasFood: $hasFood)';
}


}

/// @nodoc
abstract mixin class _$FridgeNotificationFlagsCopyWith<$Res> implements $FridgeNotificationFlagsCopyWith<$Res> {
  factory _$FridgeNotificationFlagsCopyWith(_FridgeNotificationFlags value, $Res Function(_FridgeNotificationFlags) _then) = __$FridgeNotificationFlagsCopyWithImpl;
@override @useResult
$Res call({
 bool good, bool dirty, bool outOfOrder, bool notAtLocation, bool ghost, bool noFood, bool hasFood
});




}
/// @nodoc
class __$FridgeNotificationFlagsCopyWithImpl<$Res>
    implements _$FridgeNotificationFlagsCopyWith<$Res> {
  __$FridgeNotificationFlagsCopyWithImpl(this._self, this._then);

  final _FridgeNotificationFlags _self;
  final $Res Function(_FridgeNotificationFlags) _then;

/// Create a copy of FridgeNotificationFlags
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? good = null,Object? dirty = null,Object? outOfOrder = null,Object? notAtLocation = null,Object? ghost = null,Object? noFood = null,Object? hasFood = null,}) {
  return _then(_FridgeNotificationFlags(
good: null == good ? _self.good : good // ignore: cast_nullable_to_non_nullable
as bool,dirty: null == dirty ? _self.dirty : dirty // ignore: cast_nullable_to_non_nullable
as bool,outOfOrder: null == outOfOrder ? _self.outOfOrder : outOfOrder // ignore: cast_nullable_to_non_nullable
as bool,notAtLocation: null == notAtLocation ? _self.notAtLocation : notAtLocation // ignore: cast_nullable_to_non_nullable
as bool,ghost: null == ghost ? _self.ghost : ghost // ignore: cast_nullable_to_non_nullable
as bool,noFood: null == noFood ? _self.noFood : noFood // ignore: cast_nullable_to_non_nullable
as bool,hasFood: null == hasFood ? _self.hasFood : hasFood // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
