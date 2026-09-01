// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExerciseData {

 double get distanceKm; DateTime get date; Duration? get duration; String? get healthConnectUuid;
/// Create a copy of ExerciseData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseDataCopyWith<ExerciseData> get copyWith => _$ExerciseDataCopyWithImpl<ExerciseData>(this as ExerciseData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseData&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.date, date) || other.date == date)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.healthConnectUuid, healthConnectUuid) || other.healthConnectUuid == healthConnectUuid));
}


@override
int get hashCode => Object.hash(runtimeType,distanceKm,date,duration,healthConnectUuid);

@override
String toString() {
  return 'ExerciseData(distanceKm: $distanceKm, date: $date, duration: $duration, healthConnectUuid: $healthConnectUuid)';
}


}

/// @nodoc
abstract mixin class $ExerciseDataCopyWith<$Res>  {
  factory $ExerciseDataCopyWith(ExerciseData value, $Res Function(ExerciseData) _then) = _$ExerciseDataCopyWithImpl;
@useResult
$Res call({
 double distanceKm, DateTime date, Duration? duration, String? healthConnectUuid
});




}
/// @nodoc
class _$ExerciseDataCopyWithImpl<$Res>
    implements $ExerciseDataCopyWith<$Res> {
  _$ExerciseDataCopyWithImpl(this._self, this._then);

  final ExerciseData _self;
  final $Res Function(ExerciseData) _then;

/// Create a copy of ExerciseData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? distanceKm = null,Object? date = null,Object? duration = freezed,Object? healthConnectUuid = freezed,}) {
  return _then(ExerciseData(
distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,healthConnectUuid: freezed == healthConnectUuid ? _self.healthConnectUuid : healthConnectUuid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseData].
extension ExerciseDataPatterns on ExerciseData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseData value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseData value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double distanceKm,  DateTime date,  Duration? duration,  String? healthConnectUuid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseData() when $default != null:
return $default(_that.distanceKm,_that.date,_that.duration,_that.healthConnectUuid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double distanceKm,  DateTime date,  Duration? duration,  String? healthConnectUuid)  $default,) {final _that = this;
switch (_that) {
case _ExerciseData():
return $default(_that.distanceKm,_that.date,_that.duration,_that.healthConnectUuid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double distanceKm,  DateTime date,  Duration? duration,  String? healthConnectUuid)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseData() when $default != null:
return $default(_that.distanceKm,_that.date,_that.duration,_that.healthConnectUuid);case _:
  return null;

}
}

}

/// @nodoc


class _ExerciseData implements ExerciseData {
  const _ExerciseData({required this.distanceKm, required this.date, this.duration, this.healthConnectUuid});
  

@override final  double distanceKm;
@override final  DateTime date;
@override final  Duration? duration;
@override final  String? healthConnectUuid;

/// Create a copy of ExerciseData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseDataCopyWith<_ExerciseData> get copyWith => __$ExerciseDataCopyWithImpl<_ExerciseData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseData&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.date, date) || other.date == date)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.healthConnectUuid, healthConnectUuid) || other.healthConnectUuid == healthConnectUuid));
}


@override
int get hashCode => Object.hash(runtimeType,distanceKm,date,duration,healthConnectUuid);

@override
String toString() {
  return 'ExerciseData(distanceKm: $distanceKm, date: $date, duration: $duration, healthConnectUuid: $healthConnectUuid)';
}


}

/// @nodoc
abstract mixin class _$ExerciseDataCopyWith<$Res> implements $ExerciseDataCopyWith<$Res> {
  factory _$ExerciseDataCopyWith(_ExerciseData value, $Res Function(_ExerciseData) _then) = __$ExerciseDataCopyWithImpl;
@override @useResult
$Res call({
 double distanceKm, DateTime date, Duration? duration, String? healthConnectUuid
});




}
/// @nodoc
class __$ExerciseDataCopyWithImpl<$Res>
    implements _$ExerciseDataCopyWith<$Res> {
  __$ExerciseDataCopyWithImpl(this._self, this._then);

  final _ExerciseData _self;
  final $Res Function(_ExerciseData) _then;

/// Create a copy of ExerciseData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? distanceKm = null,Object? date = null,Object? duration = freezed,Object? healthConnectUuid = freezed,}) {
  return _then(_ExerciseData(
distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,healthConnectUuid: freezed == healthConnectUuid ? _self.healthConnectUuid : healthConnectUuid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
