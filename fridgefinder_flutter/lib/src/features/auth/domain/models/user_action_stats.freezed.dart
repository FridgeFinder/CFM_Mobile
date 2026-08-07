// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_action_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserActionStats {

 String get userId; int get totalPoints; int get fridgeReportCount; int get cleanedCount; int get filledCount; int get repairedCount; DateTime get lastUpdated;
/// Create a copy of UserActionStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserActionStatsCopyWith<UserActionStats> get copyWith => _$UserActionStatsCopyWithImpl<UserActionStats>(this as UserActionStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserActionStats&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&(identical(other.fridgeReportCount, fridgeReportCount) || other.fridgeReportCount == fridgeReportCount)&&(identical(other.cleanedCount, cleanedCount) || other.cleanedCount == cleanedCount)&&(identical(other.filledCount, filledCount) || other.filledCount == filledCount)&&(identical(other.repairedCount, repairedCount) || other.repairedCount == repairedCount)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}


@override
int get hashCode => Object.hash(runtimeType,userId,totalPoints,fridgeReportCount,cleanedCount,filledCount,repairedCount,lastUpdated);

@override
String toString() {
  return 'UserActionStats(userId: $userId, totalPoints: $totalPoints, fridgeReportCount: $fridgeReportCount, cleanedCount: $cleanedCount, filledCount: $filledCount, repairedCount: $repairedCount, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $UserActionStatsCopyWith<$Res>  {
  factory $UserActionStatsCopyWith(UserActionStats value, $Res Function(UserActionStats) _then) = _$UserActionStatsCopyWithImpl;
@useResult
$Res call({
 String userId, int totalPoints, int fridgeReportCount, int cleanedCount, int filledCount, int repairedCount, DateTime lastUpdated
});




}
/// @nodoc
class _$UserActionStatsCopyWithImpl<$Res>
    implements $UserActionStatsCopyWith<$Res> {
  _$UserActionStatsCopyWithImpl(this._self, this._then);

  final UserActionStats _self;
  final $Res Function(UserActionStats) _then;

/// Create a copy of UserActionStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? totalPoints = null,Object? fridgeReportCount = null,Object? cleanedCount = null,Object? filledCount = null,Object? repairedCount = null,Object? lastUpdated = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,fridgeReportCount: null == fridgeReportCount ? _self.fridgeReportCount : fridgeReportCount // ignore: cast_nullable_to_non_nullable
as int,cleanedCount: null == cleanedCount ? _self.cleanedCount : cleanedCount // ignore: cast_nullable_to_non_nullable
as int,filledCount: null == filledCount ? _self.filledCount : filledCount // ignore: cast_nullable_to_non_nullable
as int,repairedCount: null == repairedCount ? _self.repairedCount : repairedCount // ignore: cast_nullable_to_non_nullable
as int,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UserActionStats].
extension UserActionStatsPatterns on UserActionStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserActionStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserActionStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserActionStats value)  $default,){
final _that = this;
switch (_that) {
case _UserActionStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserActionStats value)?  $default,){
final _that = this;
switch (_that) {
case _UserActionStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int totalPoints,  int fridgeReportCount,  int cleanedCount,  int filledCount,  int repairedCount,  DateTime lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserActionStats() when $default != null:
return $default(_that.userId,_that.totalPoints,_that.fridgeReportCount,_that.cleanedCount,_that.filledCount,_that.repairedCount,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int totalPoints,  int fridgeReportCount,  int cleanedCount,  int filledCount,  int repairedCount,  DateTime lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _UserActionStats():
return $default(_that.userId,_that.totalPoints,_that.fridgeReportCount,_that.cleanedCount,_that.filledCount,_that.repairedCount,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int totalPoints,  int fridgeReportCount,  int cleanedCount,  int filledCount,  int repairedCount,  DateTime lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _UserActionStats() when $default != null:
return $default(_that.userId,_that.totalPoints,_that.fridgeReportCount,_that.cleanedCount,_that.filledCount,_that.repairedCount,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc


class _UserActionStats implements UserActionStats {
  const _UserActionStats({required this.userId, required this.totalPoints, required this.fridgeReportCount, required this.cleanedCount, required this.filledCount, required this.repairedCount, required this.lastUpdated});
  

@override final  String userId;
@override final  int totalPoints;
@override final  int fridgeReportCount;
@override final  int cleanedCount;
@override final  int filledCount;
@override final  int repairedCount;
@override final  DateTime lastUpdated;

/// Create a copy of UserActionStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserActionStatsCopyWith<_UserActionStats> get copyWith => __$UserActionStatsCopyWithImpl<_UserActionStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserActionStats&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&(identical(other.fridgeReportCount, fridgeReportCount) || other.fridgeReportCount == fridgeReportCount)&&(identical(other.cleanedCount, cleanedCount) || other.cleanedCount == cleanedCount)&&(identical(other.filledCount, filledCount) || other.filledCount == filledCount)&&(identical(other.repairedCount, repairedCount) || other.repairedCount == repairedCount)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}


@override
int get hashCode => Object.hash(runtimeType,userId,totalPoints,fridgeReportCount,cleanedCount,filledCount,repairedCount,lastUpdated);

@override
String toString() {
  return 'UserActionStats(userId: $userId, totalPoints: $totalPoints, fridgeReportCount: $fridgeReportCount, cleanedCount: $cleanedCount, filledCount: $filledCount, repairedCount: $repairedCount, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$UserActionStatsCopyWith<$Res> implements $UserActionStatsCopyWith<$Res> {
  factory _$UserActionStatsCopyWith(_UserActionStats value, $Res Function(_UserActionStats) _then) = __$UserActionStatsCopyWithImpl;
@override @useResult
$Res call({
 String userId, int totalPoints, int fridgeReportCount, int cleanedCount, int filledCount, int repairedCount, DateTime lastUpdated
});




}
/// @nodoc
class __$UserActionStatsCopyWithImpl<$Res>
    implements _$UserActionStatsCopyWith<$Res> {
  __$UserActionStatsCopyWithImpl(this._self, this._then);

  final _UserActionStats _self;
  final $Res Function(_UserActionStats) _then;

/// Create a copy of UserActionStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? totalPoints = null,Object? fridgeReportCount = null,Object? cleanedCount = null,Object? filledCount = null,Object? repairedCount = null,Object? lastUpdated = null,}) {
  return _then(_UserActionStats(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,fridgeReportCount: null == fridgeReportCount ? _self.fridgeReportCount : fridgeReportCount // ignore: cast_nullable_to_non_nullable
as int,cleanedCount: null == cleanedCount ? _self.cleanedCount : cleanedCount // ignore: cast_nullable_to_non_nullable
as int,filledCount: null == filledCount ? _self.filledCount : filledCount // ignore: cast_nullable_to_non_nullable
as int,repairedCount: null == repairedCount ? _self.repairedCount : repairedCount // ignore: cast_nullable_to_non_nullable
as int,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
