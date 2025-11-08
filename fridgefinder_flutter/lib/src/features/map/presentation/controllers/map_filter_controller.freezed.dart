// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_filter_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MapFilterState {
  Set<FilterCondition> get selectedConditions =>
      throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;

  /// Create a copy of MapFilterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MapFilterStateCopyWith<MapFilterState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MapFilterStateCopyWith<$Res> {
  factory $MapFilterStateCopyWith(
          MapFilterState value, $Res Function(MapFilterState) then) =
      _$MapFilterStateCopyWithImpl<$Res, MapFilterState>;
  @useResult
  $Res call({Set<FilterCondition> selectedConditions, String searchQuery});
}

/// @nodoc
class _$MapFilterStateCopyWithImpl<$Res, $Val extends MapFilterState>
    implements $MapFilterStateCopyWith<$Res> {
  _$MapFilterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MapFilterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedConditions = null,
    Object? searchQuery = null,
  }) {
    return _then(_value.copyWith(
      selectedConditions: null == selectedConditions
          ? _value.selectedConditions
          : selectedConditions // ignore: cast_nullable_to_non_nullable
              as Set<FilterCondition>,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MapFilterStateImplCopyWith<$Res>
    implements $MapFilterStateCopyWith<$Res> {
  factory _$$MapFilterStateImplCopyWith(_$MapFilterStateImpl value,
          $Res Function(_$MapFilterStateImpl) then) =
      __$$MapFilterStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Set<FilterCondition> selectedConditions, String searchQuery});
}

/// @nodoc
class __$$MapFilterStateImplCopyWithImpl<$Res>
    extends _$MapFilterStateCopyWithImpl<$Res, _$MapFilterStateImpl>
    implements _$$MapFilterStateImplCopyWith<$Res> {
  __$$MapFilterStateImplCopyWithImpl(
      _$MapFilterStateImpl _value, $Res Function(_$MapFilterStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MapFilterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedConditions = null,
    Object? searchQuery = null,
  }) {
    return _then(_$MapFilterStateImpl(
      selectedConditions: null == selectedConditions
          ? _value._selectedConditions
          : selectedConditions // ignore: cast_nullable_to_non_nullable
              as Set<FilterCondition>,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MapFilterStateImpl extends _MapFilterState {
  const _$MapFilterStateImpl(
      {required final Set<FilterCondition> selectedConditions,
      this.searchQuery = ''})
      : _selectedConditions = selectedConditions,
        super._();

  final Set<FilterCondition> _selectedConditions;
  @override
  Set<FilterCondition> get selectedConditions {
    if (_selectedConditions is EqualUnmodifiableSetView)
      return _selectedConditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_selectedConditions);
  }

  @override
  @JsonKey()
  final String searchQuery;

  @override
  String toString() {
    return 'MapFilterState(selectedConditions: $selectedConditions, searchQuery: $searchQuery)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MapFilterStateImpl &&
            const DeepCollectionEquality()
                .equals(other._selectedConditions, _selectedConditions) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_selectedConditions), searchQuery);

  /// Create a copy of MapFilterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MapFilterStateImplCopyWith<_$MapFilterStateImpl> get copyWith =>
      __$$MapFilterStateImplCopyWithImpl<_$MapFilterStateImpl>(
          this, _$identity);
}

abstract class _MapFilterState extends MapFilterState {
  const factory _MapFilterState(
      {required final Set<FilterCondition> selectedConditions,
      final String searchQuery}) = _$MapFilterStateImpl;
  const _MapFilterState._() : super._();

  @override
  Set<FilterCondition> get selectedConditions;
  @override
  String get searchQuery;

  /// Create a copy of MapFilterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MapFilterStateImplCopyWith<_$MapFilterStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
