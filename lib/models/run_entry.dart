import 'package:freezed_annotation/freezed_annotation.dart';

part 'run_entry.freezed.dart';
part 'run_entry.g.dart';

@freezed
abstract class RunEntry with _$RunEntry {
  const factory RunEntry({
    required int id,
    required double kilometers,
    required DateTime date,
    String? notes,
    int? goalId,
  }) = _RunEntry;

  factory RunEntry.fromJson(Map<String, dynamic> json) =>
      _$RunEntryFromJson(json);
}
