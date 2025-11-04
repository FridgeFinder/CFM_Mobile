// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_filter_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapFilterState {

 Set<FilterCondition> get selectedConditions; String get searchQuery;
/// Create a copy of MapFilterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapFilterStateCopyWith<MapFilterState> get copyWith => _$MapFilterStateCopyWithImpl<MapFilterState>(this as MapFilterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapFilterState&&const DeepCollectionEquality().equals(other.selectedConditions, selectedConditions)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(selectedConditions),searchQuery);

@override
String toString() {
  return 'MapFilterState(selectedConditions: $selectedConditions, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class $MapFilterStateCopyWith<$Res>  {
  factory $MapFilterStateCopyWith(MapFilterState value, $Res Function(MapFilterState) _then) = _$MapFilterStateCopyWithImpl;
@useResult
$Res call({
 Set<FilterCondition> selectedConditions, String searchQuery
});




}
/// @nodoc
class _$MapFilterStateCopyWithImpl<$Res>
    implements $MapFilterStateCopyWith<$Res> {
  _$MapFilterStateCopyWithImpl(this._self, this._then);

  final MapFilterState _self;
  final $Res Function(MapFilterState) _then;

/// Create a copy of MapFilterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedConditions = null,Object? searchQuery = null,}) {
  return _then(_self.copyWith(
selectedConditions: null == selectedConditions ? _self.selectedConditions : selectedConditions // ignore: cast_nullable_to_non_nullable
as Set<FilterCondition>,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MapFilterState].
extension MapFilterStatePatterns on MapFilterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapFilterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapFilterState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapFilterState value)  $default,){
final _that = this;
switch (_that) {
case _MapFilterState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapFilterState value)?  $default,){
final _that = this;
switch (_that) {
case _MapFilterState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Set<FilterCondition> selectedConditions,  String searchQuery)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapFilterState() when $default != null:
return $default(_that.selectedConditions,_that.searchQuery);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Set<FilterCondition> selectedConditions,  String searchQuery)  $default,) {final _that = this;
switch (_that) {
case _MapFilterState():
return $default(_that.selectedConditions,_that.searchQuery);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Set<FilterCondition> selectedConditions,  String searchQuery)?  $default,) {final _that = this;
switch (_that) {
case _MapFilterState() when $default != null:
return $default(_that.selectedConditions,_that.searchQuery);case _:
  return null;

}
}

}

/// @nodoc


class _MapFilterState extends MapFilterState {
  const _MapFilterState({required final  Set<FilterCondition> selectedConditions, this.searchQuery = ''}): _selectedConditions = selectedConditions,super._();
  

 final  Set<FilterCondition> _selectedConditions;
@override Set<FilterCondition> get selectedConditions {
  if (_selectedConditions is EqualUnmodifiableSetView) return _selectedConditions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedConditions);
}

@override@JsonKey() final  String searchQuery;

/// Create a copy of MapFilterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapFilterStateCopyWith<_MapFilterState> get copyWith => __$MapFilterStateCopyWithImpl<_MapFilterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapFilterState&&const DeepCollectionEquality().equals(other._selectedConditions, _selectedConditions)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_selectedConditions),searchQuery);

@override
String toString() {
  return 'MapFilterState(selectedConditions: $selectedConditions, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class _$MapFilterStateCopyWith<$Res> implements $MapFilterStateCopyWith<$Res> {
  factory _$MapFilterStateCopyWith(_MapFilterState value, $Res Function(_MapFilterState) _then) = __$MapFilterStateCopyWithImpl;
@override @useResult
$Res call({
 Set<FilterCondition> selectedConditions, String searchQuery
});




}
/// @nodoc
class __$MapFilterStateCopyWithImpl<$Res>
    implements _$MapFilterStateCopyWith<$Res> {
  __$MapFilterStateCopyWithImpl(this._self, this._then);

  final _MapFilterState _self;
  final $Res Function(_MapFilterState) _then;

/// Create a copy of MapFilterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedConditions = null,Object? searchQuery = null,}) {
  return _then(_MapFilterState(
selectedConditions: null == selectedConditions ? _self._selectedConditions : selectedConditions // ignore: cast_nullable_to_non_nullable
as Set<FilterCondition>,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
