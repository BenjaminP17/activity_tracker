// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RunEntry {

 int get id; double get kilometers; DateTime get date; String? get notes; int? get goalId; String? get healthConnectUuid;
/// Create a copy of RunEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunEntryCopyWith<RunEntry> get copyWith => _$RunEntryCopyWithImpl<RunEntry>(this as RunEntry, _$identity);

  /// Serializes this RunEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.kilometers, kilometers) || other.kilometers == kilometers)&&(identical(other.date, date) || other.date == date)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.healthConnectUuid, healthConnectUuid) || other.healthConnectUuid == healthConnectUuid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kilometers,date,notes,goalId,healthConnectUuid);

@override
String toString() {
  return 'RunEntry(id: $id, kilometers: $kilometers, date: $date, notes: $notes, goalId: $goalId, healthConnectUuid: $healthConnectUuid)';
}


}

/// @nodoc
abstract mixin class $RunEntryCopyWith<$Res>  {
  factory $RunEntryCopyWith(RunEntry value, $Res Function(RunEntry) _then) = _$RunEntryCopyWithImpl;
@useResult
$Res call({
 int id, double kilometers, DateTime date, String? notes, int? goalId, String? healthConnectUuid
});




}
/// @nodoc
class _$RunEntryCopyWithImpl<$Res>
    implements $RunEntryCopyWith<$Res> {
  _$RunEntryCopyWithImpl(this._self, this._then);

  final RunEntry _self;
  final $Res Function(RunEntry) _then;

/// Create a copy of RunEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kilometers = null,Object? date = null,Object? notes = freezed,Object? goalId = freezed,Object? healthConnectUuid = freezed,}) {
  return _then(RunEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,kilometers: null == kilometers ? _self.kilometers : kilometers // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,goalId: freezed == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as int?,healthConnectUuid: freezed == healthConnectUuid ? _self.healthConnectUuid : healthConnectUuid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RunEntry].
extension RunEntryPatterns on RunEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RunEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RunEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RunEntry value)  $default,){
final _that = this;
switch (_that) {
case _RunEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RunEntry value)?  $default,){
final _that = this;
switch (_that) {
case _RunEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  double kilometers,  DateTime date,  String? notes,  int? goalId,  String? healthConnectUuid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RunEntry() when $default != null:
return $default(_that.id,_that.kilometers,_that.date,_that.notes,_that.goalId,_that.healthConnectUuid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  double kilometers,  DateTime date,  String? notes,  int? goalId,  String? healthConnectUuid)  $default,) {final _that = this;
switch (_that) {
case _RunEntry():
return $default(_that.id,_that.kilometers,_that.date,_that.notes,_that.goalId,_that.healthConnectUuid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  double kilometers,  DateTime date,  String? notes,  int? goalId,  String? healthConnectUuid)?  $default,) {final _that = this;
switch (_that) {
case _RunEntry() when $default != null:
return $default(_that.id,_that.kilometers,_that.date,_that.notes,_that.goalId,_that.healthConnectUuid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RunEntry implements RunEntry {
  const _RunEntry({required this.id, required this.kilometers, required this.date, this.notes, this.goalId, this.healthConnectUuid});
  factory _RunEntry.fromJson(Map<String, dynamic> json) => _$RunEntryFromJson(json);

@override final  int id;
@override final  double kilometers;
@override final  DateTime date;
@override final  String? notes;
@override final  int? goalId;
@override final  String? healthConnectUuid;

/// Create a copy of RunEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunEntryCopyWith<_RunEntry> get copyWith => __$RunEntryCopyWithImpl<_RunEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RunEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RunEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.kilometers, kilometers) || other.kilometers == kilometers)&&(identical(other.date, date) || other.date == date)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.healthConnectUuid, healthConnectUuid) || other.healthConnectUuid == healthConnectUuid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kilometers,date,notes,goalId,healthConnectUuid);

@override
String toString() {
  return 'RunEntry(id: $id, kilometers: $kilometers, date: $date, notes: $notes, goalId: $goalId, healthConnectUuid: $healthConnectUuid)';
}


}

/// @nodoc
abstract mixin class _$RunEntryCopyWith<$Res> implements $RunEntryCopyWith<$Res> {
  factory _$RunEntryCopyWith(_RunEntry value, $Res Function(_RunEntry) _then) = __$RunEntryCopyWithImpl;
@override @useResult
$Res call({
 int id, double kilometers, DateTime date, String? notes, int? goalId, String? healthConnectUuid
});




}
/// @nodoc
class __$RunEntryCopyWithImpl<$Res>
    implements _$RunEntryCopyWith<$Res> {
  __$RunEntryCopyWithImpl(this._self, this._then);

  final _RunEntry _self;
  final $Res Function(_RunEntry) _then;

/// Create a copy of RunEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kilometers = null,Object? date = null,Object? notes = freezed,Object? goalId = freezed,Object? healthConnectUuid = freezed,}) {
  return _then(_RunEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,kilometers: null == kilometers ? _self.kilometers : kilometers // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,goalId: freezed == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as int?,healthConnectUuid: freezed == healthConnectUuid ? _self.healthConnectUuid : healthConnectUuid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
