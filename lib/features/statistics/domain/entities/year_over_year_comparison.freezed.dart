// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'year_over_year_comparison.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

YearOverYearComparison _$YearOverYearComparisonFromJson(
  Map<String, dynamic> json,
) {
  return _YearOverYearComparison.fromJson(json);
}

/// @nodoc
mixin _$YearOverYearComparison {
  int get year1 => throw _privateConstructorUsedError;
  int get year2 => throw _privateConstructorUsedError;
  List<double> get year1Monthly =>
      throw _privateConstructorUsedError; // 12 elements (Jan-Dec)
  List<double> get year2Monthly => throw _privateConstructorUsedError;

  /// Serializes this YearOverYearComparison to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of YearOverYearComparison
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $YearOverYearComparisonCopyWith<YearOverYearComparison> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YearOverYearComparisonCopyWith<$Res> {
  factory $YearOverYearComparisonCopyWith(
    YearOverYearComparison value,
    $Res Function(YearOverYearComparison) then,
  ) = _$YearOverYearComparisonCopyWithImpl<$Res, YearOverYearComparison>;
  @useResult
  $Res call({
    int year1,
    int year2,
    List<double> year1Monthly,
    List<double> year2Monthly,
  });
}

/// @nodoc
class _$YearOverYearComparisonCopyWithImpl<
  $Res,
  $Val extends YearOverYearComparison
>
    implements $YearOverYearComparisonCopyWith<$Res> {
  _$YearOverYearComparisonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of YearOverYearComparison
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year1 = null,
    Object? year2 = null,
    Object? year1Monthly = null,
    Object? year2Monthly = null,
  }) {
    return _then(
      _value.copyWith(
            year1: null == year1
                ? _value.year1
                : year1 // ignore: cast_nullable_to_non_nullable
                      as int,
            year2: null == year2
                ? _value.year2
                : year2 // ignore: cast_nullable_to_non_nullable
                      as int,
            year1Monthly: null == year1Monthly
                ? _value.year1Monthly
                : year1Monthly // ignore: cast_nullable_to_non_nullable
                      as List<double>,
            year2Monthly: null == year2Monthly
                ? _value.year2Monthly
                : year2Monthly // ignore: cast_nullable_to_non_nullable
                      as List<double>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$YearOverYearComparisonImplCopyWith<$Res>
    implements $YearOverYearComparisonCopyWith<$Res> {
  factory _$$YearOverYearComparisonImplCopyWith(
    _$YearOverYearComparisonImpl value,
    $Res Function(_$YearOverYearComparisonImpl) then,
  ) = __$$YearOverYearComparisonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int year1,
    int year2,
    List<double> year1Monthly,
    List<double> year2Monthly,
  });
}

/// @nodoc
class __$$YearOverYearComparisonImplCopyWithImpl<$Res>
    extends
        _$YearOverYearComparisonCopyWithImpl<$Res, _$YearOverYearComparisonImpl>
    implements _$$YearOverYearComparisonImplCopyWith<$Res> {
  __$$YearOverYearComparisonImplCopyWithImpl(
    _$YearOverYearComparisonImpl _value,
    $Res Function(_$YearOverYearComparisonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of YearOverYearComparison
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year1 = null,
    Object? year2 = null,
    Object? year1Monthly = null,
    Object? year2Monthly = null,
  }) {
    return _then(
      _$YearOverYearComparisonImpl(
        year1: null == year1
            ? _value.year1
            : year1 // ignore: cast_nullable_to_non_nullable
                  as int,
        year2: null == year2
            ? _value.year2
            : year2 // ignore: cast_nullable_to_non_nullable
                  as int,
        year1Monthly: null == year1Monthly
            ? _value._year1Monthly
            : year1Monthly // ignore: cast_nullable_to_non_nullable
                  as List<double>,
        year2Monthly: null == year2Monthly
            ? _value._year2Monthly
            : year2Monthly // ignore: cast_nullable_to_non_nullable
                  as List<double>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$YearOverYearComparisonImpl implements _YearOverYearComparison {
  const _$YearOverYearComparisonImpl({
    required this.year1,
    required this.year2,
    required final List<double> year1Monthly,
    required final List<double> year2Monthly,
  }) : _year1Monthly = year1Monthly,
       _year2Monthly = year2Monthly;

  factory _$YearOverYearComparisonImpl.fromJson(Map<String, dynamic> json) =>
      _$$YearOverYearComparisonImplFromJson(json);

  @override
  final int year1;
  @override
  final int year2;
  final List<double> _year1Monthly;
  @override
  List<double> get year1Monthly {
    if (_year1Monthly is EqualUnmodifiableListView) return _year1Monthly;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_year1Monthly);
  }

  // 12 elements (Jan-Dec)
  final List<double> _year2Monthly;
  // 12 elements (Jan-Dec)
  @override
  List<double> get year2Monthly {
    if (_year2Monthly is EqualUnmodifiableListView) return _year2Monthly;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_year2Monthly);
  }

  @override
  String toString() {
    return 'YearOverYearComparison(year1: $year1, year2: $year2, year1Monthly: $year1Monthly, year2Monthly: $year2Monthly)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YearOverYearComparisonImpl &&
            (identical(other.year1, year1) || other.year1 == year1) &&
            (identical(other.year2, year2) || other.year2 == year2) &&
            const DeepCollectionEquality().equals(
              other._year1Monthly,
              _year1Monthly,
            ) &&
            const DeepCollectionEquality().equals(
              other._year2Monthly,
              _year2Monthly,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    year1,
    year2,
    const DeepCollectionEquality().hash(_year1Monthly),
    const DeepCollectionEquality().hash(_year2Monthly),
  );

  /// Create a copy of YearOverYearComparison
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$YearOverYearComparisonImplCopyWith<_$YearOverYearComparisonImpl>
  get copyWith =>
      __$$YearOverYearComparisonImplCopyWithImpl<_$YearOverYearComparisonImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$YearOverYearComparisonImplToJson(this);
  }
}

abstract class _YearOverYearComparison implements YearOverYearComparison {
  const factory _YearOverYearComparison({
    required final int year1,
    required final int year2,
    required final List<double> year1Monthly,
    required final List<double> year2Monthly,
  }) = _$YearOverYearComparisonImpl;

  factory _YearOverYearComparison.fromJson(Map<String, dynamic> json) =
      _$YearOverYearComparisonImpl.fromJson;

  @override
  int get year1;
  @override
  int get year2;
  @override
  List<double> get year1Monthly; // 12 elements (Jan-Dec)
  @override
  List<double> get year2Monthly;

  /// Create a copy of YearOverYearComparison
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$YearOverYearComparisonImplCopyWith<_$YearOverYearComparisonImpl>
  get copyWith => throw _privateConstructorUsedError;
}
