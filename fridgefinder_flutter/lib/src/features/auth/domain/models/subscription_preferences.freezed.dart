// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionPreferences {

 String get fridgeId;@JsonKey(toJson: _dateTimeToJson, fromJson: _dateTimeFromJson) DateTime get subscribedAt;@JsonKey(toJson: _notificationPreferencesToJson) NotificationPreferences get notificationPreferences;
/// Create a copy of SubscriptionPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionPreferencesCopyWith<SubscriptionPreferences> get copyWith => _$SubscriptionPreferencesCopyWithImpl<SubscriptionPreferences>(this as SubscriptionPreferences, _$identity);

  /// Serializes this SubscriptionPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionPreferences&&(identical(other.fridgeId, fridgeId) || other.fridgeId == fridgeId)&&(identical(other.subscribedAt, subscribedAt) || other.subscribedAt == subscribedAt)&&(identical(other.notificationPreferences, notificationPreferences) || other.notificationPreferences == notificationPreferences));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fridgeId,subscribedAt,notificationPreferences);

@override
String toString() {
  return 'SubscriptionPreferences(fridgeId: $fridgeId, subscribedAt: $subscribedAt, notificationPreferences: $notificationPreferences)';
}


}

/// @nodoc
abstract mixin class $SubscriptionPreferencesCopyWith<$Res>  {
  factory $SubscriptionPreferencesCopyWith(SubscriptionPreferences value, $Res Function(SubscriptionPreferences) _then) = _$SubscriptionPreferencesCopyWithImpl;
@useResult
$Res call({
 String fridgeId,@JsonKey(toJson: _dateTimeToJson, fromJson: _dateTimeFromJson) DateTime subscribedAt,@JsonKey(toJson: _notificationPreferencesToJson) NotificationPreferences notificationPreferences
});


$NotificationPreferencesCopyWith<$Res> get notificationPreferences;

}
/// @nodoc
class _$SubscriptionPreferencesCopyWithImpl<$Res>
    implements $SubscriptionPreferencesCopyWith<$Res> {
  _$SubscriptionPreferencesCopyWithImpl(this._self, this._then);

  final SubscriptionPreferences _self;
  final $Res Function(SubscriptionPreferences) _then;

/// Create a copy of SubscriptionPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fridgeId = null,Object? subscribedAt = null,Object? notificationPreferences = null,}) {
  return _then(_self.copyWith(
fridgeId: null == fridgeId ? _self.fridgeId : fridgeId // ignore: cast_nullable_to_non_nullable
as String,subscribedAt: null == subscribedAt ? _self.subscribedAt : subscribedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notificationPreferences: null == notificationPreferences ? _self.notificationPreferences : notificationPreferences // ignore: cast_nullable_to_non_nullable
as NotificationPreferences,
  ));
}
/// Create a copy of SubscriptionPreferences
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<$Res> get notificationPreferences {
  
  return $NotificationPreferencesCopyWith<$Res>(_self.notificationPreferences, (value) {
    return _then(_self.copyWith(notificationPreferences: value));
  });
}
}


/// Adds pattern-matching-related methods to [SubscriptionPreferences].
extension SubscriptionPreferencesPatterns on SubscriptionPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionPreferences value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fridgeId, @JsonKey(toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)  DateTime subscribedAt, @JsonKey(toJson: _notificationPreferencesToJson)  NotificationPreferences notificationPreferences)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionPreferences() when $default != null:
return $default(_that.fridgeId,_that.subscribedAt,_that.notificationPreferences);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fridgeId, @JsonKey(toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)  DateTime subscribedAt, @JsonKey(toJson: _notificationPreferencesToJson)  NotificationPreferences notificationPreferences)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionPreferences():
return $default(_that.fridgeId,_that.subscribedAt,_that.notificationPreferences);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fridgeId, @JsonKey(toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)  DateTime subscribedAt, @JsonKey(toJson: _notificationPreferencesToJson)  NotificationPreferences notificationPreferences)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionPreferences() when $default != null:
return $default(_that.fridgeId,_that.subscribedAt,_that.notificationPreferences);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionPreferences extends SubscriptionPreferences {
  const _SubscriptionPreferences({required this.fridgeId, @JsonKey(toJson: _dateTimeToJson, fromJson: _dateTimeFromJson) required this.subscribedAt, @JsonKey(toJson: _notificationPreferencesToJson) this.notificationPreferences = const NotificationPreferences()}): super._();
  factory _SubscriptionPreferences.fromJson(Map<String, dynamic> json) => _$SubscriptionPreferencesFromJson(json);

@override final  String fridgeId;
@override@JsonKey(toJson: _dateTimeToJson, fromJson: _dateTimeFromJson) final  DateTime subscribedAt;
@override@JsonKey(toJson: _notificationPreferencesToJson) final  NotificationPreferences notificationPreferences;

/// Create a copy of SubscriptionPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionPreferencesCopyWith<_SubscriptionPreferences> get copyWith => __$SubscriptionPreferencesCopyWithImpl<_SubscriptionPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionPreferences&&(identical(other.fridgeId, fridgeId) || other.fridgeId == fridgeId)&&(identical(other.subscribedAt, subscribedAt) || other.subscribedAt == subscribedAt)&&(identical(other.notificationPreferences, notificationPreferences) || other.notificationPreferences == notificationPreferences));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fridgeId,subscribedAt,notificationPreferences);

@override
String toString() {
  return 'SubscriptionPreferences(fridgeId: $fridgeId, subscribedAt: $subscribedAt, notificationPreferences: $notificationPreferences)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionPreferencesCopyWith<$Res> implements $SubscriptionPreferencesCopyWith<$Res> {
  factory _$SubscriptionPreferencesCopyWith(_SubscriptionPreferences value, $Res Function(_SubscriptionPreferences) _then) = __$SubscriptionPreferencesCopyWithImpl;
@override @useResult
$Res call({
 String fridgeId,@JsonKey(toJson: _dateTimeToJson, fromJson: _dateTimeFromJson) DateTime subscribedAt,@JsonKey(toJson: _notificationPreferencesToJson) NotificationPreferences notificationPreferences
});


@override $NotificationPreferencesCopyWith<$Res> get notificationPreferences;

}
/// @nodoc
class __$SubscriptionPreferencesCopyWithImpl<$Res>
    implements _$SubscriptionPreferencesCopyWith<$Res> {
  __$SubscriptionPreferencesCopyWithImpl(this._self, this._then);

  final _SubscriptionPreferences _self;
  final $Res Function(_SubscriptionPreferences) _then;

/// Create a copy of SubscriptionPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fridgeId = null,Object? subscribedAt = null,Object? notificationPreferences = null,}) {
  return _then(_SubscriptionPreferences(
fridgeId: null == fridgeId ? _self.fridgeId : fridgeId // ignore: cast_nullable_to_non_nullable
as String,subscribedAt: null == subscribedAt ? _self.subscribedAt : subscribedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notificationPreferences: null == notificationPreferences ? _self.notificationPreferences : notificationPreferences // ignore: cast_nullable_to_non_nullable
as NotificationPreferences,
  ));
}

/// Create a copy of SubscriptionPreferences
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

 bool get updatedWithFood; bool get runningLow; bool get empty; bool get needsCleaning; bool get needsServicing; bool get routineValidation;
/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<NotificationPreferences> get copyWith => _$NotificationPreferencesCopyWithImpl<NotificationPreferences>(this as NotificationPreferences, _$identity);

  /// Serializes this NotificationPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPreferences&&(identical(other.updatedWithFood, updatedWithFood) || other.updatedWithFood == updatedWithFood)&&(identical(other.runningLow, runningLow) || other.runningLow == runningLow)&&(identical(other.empty, empty) || other.empty == empty)&&(identical(other.needsCleaning, needsCleaning) || other.needsCleaning == needsCleaning)&&(identical(other.needsServicing, needsServicing) || other.needsServicing == needsServicing)&&(identical(other.routineValidation, routineValidation) || other.routineValidation == routineValidation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,updatedWithFood,runningLow,empty,needsCleaning,needsServicing,routineValidation);

@override
String toString() {
  return 'NotificationPreferences(updatedWithFood: $updatedWithFood, runningLow: $runningLow, empty: $empty, needsCleaning: $needsCleaning, needsServicing: $needsServicing, routineValidation: $routineValidation)';
}


}

/// @nodoc
abstract mixin class $NotificationPreferencesCopyWith<$Res>  {
  factory $NotificationPreferencesCopyWith(NotificationPreferences value, $Res Function(NotificationPreferences) _then) = _$NotificationPreferencesCopyWithImpl;
@useResult
$Res call({
 bool updatedWithFood, bool runningLow, bool empty, bool needsCleaning, bool needsServicing, bool routineValidation
});




}
/// @nodoc
class _$NotificationPreferencesCopyWithImpl<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  _$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final NotificationPreferences _self;
  final $Res Function(NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? updatedWithFood = null,Object? runningLow = null,Object? empty = null,Object? needsCleaning = null,Object? needsServicing = null,Object? routineValidation = null,}) {
  return _then(_self.copyWith(
updatedWithFood: null == updatedWithFood ? _self.updatedWithFood : updatedWithFood // ignore: cast_nullable_to_non_nullable
as bool,runningLow: null == runningLow ? _self.runningLow : runningLow // ignore: cast_nullable_to_non_nullable
as bool,empty: null == empty ? _self.empty : empty // ignore: cast_nullable_to_non_nullable
as bool,needsCleaning: null == needsCleaning ? _self.needsCleaning : needsCleaning // ignore: cast_nullable_to_non_nullable
as bool,needsServicing: null == needsServicing ? _self.needsServicing : needsServicing // ignore: cast_nullable_to_non_nullable
as bool,routineValidation: null == routineValidation ? _self.routineValidation : routineValidation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool updatedWithFood,  bool runningLow,  bool empty,  bool needsCleaning,  bool needsServicing,  bool routineValidation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.updatedWithFood,_that.runningLow,_that.empty,_that.needsCleaning,_that.needsServicing,_that.routineValidation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool updatedWithFood,  bool runningLow,  bool empty,  bool needsCleaning,  bool needsServicing,  bool routineValidation)  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences():
return $default(_that.updatedWithFood,_that.runningLow,_that.empty,_that.needsCleaning,_that.needsServicing,_that.routineValidation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool updatedWithFood,  bool runningLow,  bool empty,  bool needsCleaning,  bool needsServicing,  bool routineValidation)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.updatedWithFood,_that.runningLow,_that.empty,_that.needsCleaning,_that.needsServicing,_that.routineValidation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPreferences extends NotificationPreferences {
  const _NotificationPreferences({this.updatedWithFood = false, this.runningLow = false, this.empty = false, this.needsCleaning = false, this.needsServicing = false, this.routineValidation = false}): super._();
  factory _NotificationPreferences.fromJson(Map<String, dynamic> json) => _$NotificationPreferencesFromJson(json);

@override@JsonKey() final  bool updatedWithFood;
@override@JsonKey() final  bool runningLow;
@override@JsonKey() final  bool empty;
@override@JsonKey() final  bool needsCleaning;
@override@JsonKey() final  bool needsServicing;
@override@JsonKey() final  bool routineValidation;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPreferences&&(identical(other.updatedWithFood, updatedWithFood) || other.updatedWithFood == updatedWithFood)&&(identical(other.runningLow, runningLow) || other.runningLow == runningLow)&&(identical(other.empty, empty) || other.empty == empty)&&(identical(other.needsCleaning, needsCleaning) || other.needsCleaning == needsCleaning)&&(identical(other.needsServicing, needsServicing) || other.needsServicing == needsServicing)&&(identical(other.routineValidation, routineValidation) || other.routineValidation == routineValidation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,updatedWithFood,runningLow,empty,needsCleaning,needsServicing,routineValidation);

@override
String toString() {
  return 'NotificationPreferences(updatedWithFood: $updatedWithFood, runningLow: $runningLow, empty: $empty, needsCleaning: $needsCleaning, needsServicing: $needsServicing, routineValidation: $routineValidation)';
}


}

/// @nodoc
abstract mixin class _$NotificationPreferencesCopyWith<$Res> implements $NotificationPreferencesCopyWith<$Res> {
  factory _$NotificationPreferencesCopyWith(_NotificationPreferences value, $Res Function(_NotificationPreferences) _then) = __$NotificationPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool updatedWithFood, bool runningLow, bool empty, bool needsCleaning, bool needsServicing, bool routineValidation
});




}
/// @nodoc
class __$NotificationPreferencesCopyWithImpl<$Res>
    implements _$NotificationPreferencesCopyWith<$Res> {
  __$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final _NotificationPreferences _self;
  final $Res Function(_NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? updatedWithFood = null,Object? runningLow = null,Object? empty = null,Object? needsCleaning = null,Object? needsServicing = null,Object? routineValidation = null,}) {
  return _then(_NotificationPreferences(
updatedWithFood: null == updatedWithFood ? _self.updatedWithFood : updatedWithFood // ignore: cast_nullable_to_non_nullable
as bool,runningLow: null == runningLow ? _self.runningLow : runningLow // ignore: cast_nullable_to_non_nullable
as bool,empty: null == empty ? _self.empty : empty // ignore: cast_nullable_to_non_nullable
as bool,needsCleaning: null == needsCleaning ? _self.needsCleaning : needsCleaning // ignore: cast_nullable_to_non_nullable
as bool,needsServicing: null == needsServicing ? _self.needsServicing : needsServicing // ignore: cast_nullable_to_non_nullable
as bool,routineValidation: null == routineValidation ? _self.routineValidation : routineValidation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
