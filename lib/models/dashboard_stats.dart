import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats.freezed.dart';
part 'dashboard_stats.g.dart';

@freezed
abstract class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    required double totalKm,
    required double remainingKm,
    required int weeksRemaining,
    required double weeklyAverageNeeded,
    required bool goalCompleted,
    required double progressPercent,
    required double targetKm,
    required DateTime? targetDate,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);

  /// The stats shown when there is no active goal.
  factory DashboardStats.empty() => const DashboardStats(
        totalKm: 0,
        remainingKm: 0,
        weeksRemaining: 0,
        weeklyAverageNeeded: 0,
        goalCompleted: false,
        progressPercent: 0,
        targetKm: 0,
        targetDate: null,
      );
}
