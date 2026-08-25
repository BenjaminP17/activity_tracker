// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardStats {

 double get totalKm; double get remainingKm; int get weeksRemaining; double get weeklyAverageNeeded; bool get goalCompleted; double get progressPercent;
/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStatsCopyWith<DashboardStats> get copyWith => _$DashboardStatsCopyWithImpl<DashboardStats>(this as DashboardStats, _$identity);

  /// Serializes this DashboardStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardStats&&(identical(other.totalKm, totalKm) || other.totalKm == totalKm)&&(identical(other.remainingKm, remainingKm) || other.remainingKm == remainingKm)&&(identical(other.weeksRemaining, weeksRemaining) || other.weeksRemaining == weeksRemaining)&&(identical(other.weeklyAverageNeeded, weeklyAverageNeeded) || other.weeklyAverageNeeded == weeklyAverageNeeded)&&(identical(other.goalCompleted, goalCompleted) || other.goalCompleted == goalCompleted)&&(identical(other.progressPercent, progressPercent) || other.progressPercent == progressPercent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalKm,remainingKm,weeksRemaining,weeklyAverageNeeded,goalCompleted,progressPercent);

@override
String toString() {
  return 'DashboardStats(totalKm: $totalKm, remainingKm: $remainingKm, weeksRemaining: $weeksRemaining, weeklyAverageNeeded: $weeklyAverageNeeded, goalCompleted: $goalCompleted, progressPercent: $progressPercent)';
}


}

/// @nodoc
abstract mixin class $DashboardStatsCopyWith<$Res>  {
  factory $DashboardStatsCopyWith(DashboardStats value, $Res Function(DashboardStats) _then) = _$DashboardStatsCopyWithImpl;
@useResult
$Res call({
 double totalKm, double remainingKm, int weeksRemaining, double weeklyAverageNeeded, bool goalCompleted, double progressPercent
});




}
/// @nodoc
class _$DashboardStatsCopyWithImpl<$Res>
    implements $DashboardStatsCopyWith<$Res> {
  _$DashboardStatsCopyWithImpl(this._self, this._then);

  final DashboardStats _self;
  final $Res Function(DashboardStats) _then;

/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalKm = null,Object? remainingKm = null,Object? weeksRemaining = null,Object? weeklyAverageNeeded = null,Object? goalCompleted = null,Object? progressPercent = null,}) {
  return _then(DashboardStats(
totalKm: null == totalKm ? _self.totalKm : totalKm // ignore: cast_nullable_to_non_nullable
as double,remainingKm: null == remainingKm ? _self.remainingKm : remainingKm // ignore: cast_nullable_to_non_nullable
as double,weeksRemaining: null == weeksRemaining ? _self.weeksRemaining : weeksRemaining // ignore: cast_nullable_to_non_nullable
as int,weeklyAverageNeeded: null == weeklyAverageNeeded ? _self.weeklyAverageNeeded : weeklyAverageNeeded // ignore: cast_nullable_to_non_nullable
as double,goalCompleted: null == goalCompleted ? _self.goalCompleted : goalCompleted // ignore: cast_nullable_to_non_nullable
as bool,progressPercent: null == progressPercent ? _self.progressPercent : progressPercent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardStats].
extension DashboardStatsPatterns on DashboardStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardStats value)  $default,){
final _that = this;
switch (_that) {
case _DashboardStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardStats value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalKm,  double remainingKm,  int weeksRemaining,  double weeklyAverageNeeded,  bool goalCompleted,  double progressPercent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
return $default(_that.totalKm,_that.remainingKm,_that.weeksRemaining,_that.weeklyAverageNeeded,_that.goalCompleted,_that.progressPercent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalKm,  double remainingKm,  int weeksRemaining,  double weeklyAverageNeeded,  bool goalCompleted,  double progressPercent)  $default,) {final _that = this;
switch (_that) {
case _DashboardStats():
return $default(_that.totalKm,_that.remainingKm,_that.weeksRemaining,_that.weeklyAverageNeeded,_that.goalCompleted,_that.progressPercent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalKm,  double remainingKm,  int weeksRemaining,  double weeklyAverageNeeded,  bool goalCompleted,  double progressPercent)?  $default,) {final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
return $default(_that.totalKm,_that.remainingKm,_that.weeksRemaining,_that.weeklyAverageNeeded,_that.goalCompleted,_that.progressPercent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardStats implements DashboardStats {
  const _DashboardStats({required this.totalKm, required this.remainingKm, required this.weeksRemaining, required this.weeklyAverageNeeded, required this.goalCompleted, required this.progressPercent});
  factory _DashboardStats.fromJson(Map<String, dynamic> json) => _$DashboardStatsFromJson(json);

@override final  double totalKm;
@override final  double remainingKm;
@override final  int weeksRemaining;
@override final  double weeklyAverageNeeded;
@override final  bool goalCompleted;
@override final  double progressPercent;

/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStatsCopyWith<_DashboardStats> get copyWith => __$DashboardStatsCopyWithImpl<_DashboardStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardStats&&(identical(other.totalKm, totalKm) || other.totalKm == totalKm)&&(identical(other.remainingKm, remainingKm) || other.remainingKm == remainingKm)&&(identical(other.weeksRemaining, weeksRemaining) || other.weeksRemaining == weeksRemaining)&&(identical(other.weeklyAverageNeeded, weeklyAverageNeeded) || other.weeklyAverageNeeded == weeklyAverageNeeded)&&(identical(other.goalCompleted, goalCompleted) || other.goalCompleted == goalCompleted)&&(identical(other.progressPercent, progressPercent) || other.progressPercent == progressPercent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalKm,remainingKm,weeksRemaining,weeklyAverageNeeded,goalCompleted,progressPercent);

@override
String toString() {
  return 'DashboardStats(totalKm: $totalKm, remainingKm: $remainingKm, weeksRemaining: $weeksRemaining, weeklyAverageNeeded: $weeklyAverageNeeded, goalCompleted: $goalCompleted, progressPercent: $progressPercent)';
}


}

/// @nodoc
abstract mixin class _$DashboardStatsCopyWith<$Res> implements $DashboardStatsCopyWith<$Res> {
  factory _$DashboardStatsCopyWith(_DashboardStats value, $Res Function(_DashboardStats) _then) = __$DashboardStatsCopyWithImpl;
@override @useResult
$Res call({
 double totalKm, double remainingKm, int weeksRemaining, double weeklyAverageNeeded, bool goalCompleted, double progressPercent
});




}
/// @nodoc
class __$DashboardStatsCopyWithImpl<$Res>
    implements _$DashboardStatsCopyWith<$Res> {
  __$DashboardStatsCopyWithImpl(this._self, this._then);

  final _DashboardStats _self;
  final $Res Function(_DashboardStats) _then;

/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalKm = null,Object? remainingKm = null,Object? weeksRemaining = null,Object? weeklyAverageNeeded = null,Object? goalCompleted = null,Object? progressPercent = null,}) {
  return _then(_DashboardStats(
totalKm: null == totalKm ? _self.totalKm : totalKm // ignore: cast_nullable_to_non_nullable
as double,remainingKm: null == remainingKm ? _self.remainingKm : remainingKm // ignore: cast_nullable_to_non_nullable
as double,weeksRemaining: null == weeksRemaining ? _self.weeksRemaining : weeksRemaining // ignore: cast_nullable_to_non_nullable
as int,weeklyAverageNeeded: null == weeklyAverageNeeded ? _self.weeklyAverageNeeded : weeklyAverageNeeded // ignore: cast_nullable_to_non_nullable
as double,goalCompleted: null == goalCompleted ? _self.goalCompleted : goalCompleted // ignore: cast_nullable_to_non_nullable
as bool,progressPercent: null == progressPercent ? _self.progressPercent : progressPercent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
