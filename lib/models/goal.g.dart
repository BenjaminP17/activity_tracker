// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Goal _$GoalFromJson(Map<String, dynamic> json) => _Goal(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  targetKm: (json['targetKm'] as num).toDouble(),
  targetDate: DateTime.parse(json['targetDate'] as String),
  activityType: $enumDecode(_$ActivityTypeEnumMap, json['activityType']),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$GoalToJson(_Goal instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'targetKm': instance.targetKm,
  'targetDate': instance.targetDate.toIso8601String(),
  'activityType': _$ActivityTypeEnumMap[instance.activityType]!,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$ActivityTypeEnumMap = {
  ActivityType.running: 'running',
  ActivityType.cycling: 'cycling',
  ActivityType.swimming: 'swimming',
  ActivityType.hiking: 'hiking',
};
