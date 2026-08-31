// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RunEntry _$RunEntryFromJson(Map<String, dynamic> json) => _RunEntry(
  id: (json['id'] as num).toInt(),
  kilometers: (json['kilometers'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
  notes: json['notes'] as String?,
  goalId: (json['goalId'] as num?)?.toInt(),
  healthConnectUuid: json['healthConnectUuid'] as String?,
);

Map<String, dynamic> _$RunEntryToJson(_RunEntry instance) => <String, dynamic>{
  'id': instance.id,
  'kilometers': instance.kilometers,
  'date': instance.date.toIso8601String(),
  'notes': instance.notes,
  'goalId': instance.goalId,
  'healthConnectUuid': instance.healthConnectUuid,
};
