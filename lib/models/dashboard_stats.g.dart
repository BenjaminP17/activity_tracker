// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
    _DashboardStats(
      totalKm: (json['totalKm'] as num).toDouble(),
      remainingKm: (json['remainingKm'] as num).toDouble(),
      weeksRemaining: (json['weeksRemaining'] as num).toInt(),
      weeklyAverageNeeded: (json['weeklyAverageNeeded'] as num).toDouble(),
      goalCompleted: json['goalCompleted'] as bool,
      progressPercent: (json['progressPercent'] as num).toDouble(),
    );

Map<String, dynamic> _$DashboardStatsToJson(_DashboardStats instance) =>
    <String, dynamic>{
      'totalKm': instance.totalKm,
      'remainingKm': instance.remainingKm,
      'weeksRemaining': instance.weeksRemaining,
      'weeklyAverageNeeded': instance.weeklyAverageNeeded,
      'goalCompleted': instance.goalCompleted,
      'progressPercent': instance.progressPercent,
    };
