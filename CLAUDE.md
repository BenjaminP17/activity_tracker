# Activity Tracker App

## Stack

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod (AsyncNotifier pattern)
- **Local Storage:** SQLite (sqflite) - schema v6 with migrations
- **Health Integration:** Health Connect API (Strava sync)
- **Data Serialization:** Freezed + JsonSerializable
- **Date Formatting:** intl
- **Target:** Android (Pixel 7)

## Project Structure

benjamin@benjamin-Inspiron-16-5625:~/Projets/activity_tracker$ tree -L 3 -I 'node_modules|build|.git|.dart_tool|.pub-cache' lib/
lib/
├── main.dart
├── models
│   ├── activity_type.dart
│   ├── dashboard_stats.dart
│   ├── dashboard_stats.freezed.dart
│   ├── dashboard_stats.g.dart
│   ├── exercise_data.dart
│   ├── exercise_data.freezed.dart
│   ├── goal.dart
│   ├── goal.freezed.dart
│   ├── goal.g.dart
│   ├── run_entry.dart
│   ├── run_entry.freezed.dart
│   └── run_entry.g.dart
├── providers
│   ├── dashboard_provider.dart
│   ├── goal_provider.dart
│   ├── health_connect_provider.dart
│   ├── providers.dart
│   └── run_provider.dart
├── screens
│   ├── add_run_screen.dart
│   ├── dashboard_screen.dart
│   ├── goals_list_screen.dart
│   ├── onboarding_screen.dart
│   ├── run_history_screen.dart
│   └── showcase_screen.dart
├── services
│   ├── database_service.dart
│   ├── goal_service.dart
│   └── health_connect_service.dart
├── theme
│   ├── app_colors.dart
│   ├── app_spacing.dart
│   └── app_theme.dart
└── widgets
├── app_button.dart
├── app_card.dart
├── app_text_field.dart
└── stats_card.dart

7 directories, 34 files

## Architecture Rules

- **Separation of concerns:** models ≠ services ≠ providers ≠ screens
- **One file, one class:** every service/model/provider in its own file
- **File size limit:** max 300 lines per file
- **Services:** pure business logic + database access (no Riverpod dependency)
- **Providers:** state management via AsyncNotifier (no business logic here)
- **Screens:** UI only, delegate logic to providers

## Design System (Trade République-inspired)

- **Primary:** #0066FF (blue)
- **Accent:** #10B981 (green - success)
- **Background:** #FFFFFF (white)
- **Surface:** #F9FAFB (light gray)
- **Text:** #111827 (dark gray)
- **Text Secondary:** #6B7280 (medium gray)
- **Border:** #E5E7EB (light border)
- **Error:** #EF4444 (red)

**Spacing scale:** 4, 8, 16, 24, 32, 48 (multiples of 8)
**Radius:** 8px (buttons, inputs), 12px (cards)

## Models

### RunEntry

- id (int), goalId (int?), distanceKm (double), date (DateTime), notes (String?)
- healthConnectUuid (String?) — for deduplication

### Goal

- id (int), name (String), targetKm (double), targetDate (DateTime)
- activityType (ActivityType), isActive (bool)
- completionStatus (GoalCompletionStatus), completedAt (DateTime?)
- createdAt (DateTime)

### DashboardStats

- totalKm, remainingKm, weeklyAverageNeeded, progressPercent
- targetKm, targetDate

### ExerciseData

- distanceKm (double), date (DateTime), duration (int?)

### ActivityType

- enum: running, cycling, swimming, hiking (extensible)

## Database

- SQLite schema v6 (versioned migrations)
- Tables: runs, goals
- Foreign keys enabled (PRAGMA foreign_keys = ON)
- UUIDs for deduplication (Health Connect)

## Code Standards

### Structure

- One class/service = one file
- lib/services/ for business logic
- lib/providers/ for Riverpod notifiers
- lib/models/ for data classes
- Avoid files > 300 lines

### Dart Conventions

- camelCase for variables/methods, PascalCase for classes
- Always explicitly type return types
- Const constructors when possible
- Null safety: avoid !, prefer ??
- Document public methods with /// comments

### Architecture

- Separation of concerns: models ≠ services ≠ providers
- Services: business logic + persistence, no Riverpod
- Providers: state management, data exposure
- No complex UI logic outside screens

### Riverpod Best Practices

- Use AsyncNotifier for async operations
- No mutable global state
- Explicit provider dependencies (via .select())
- Invalidate downstream providers after mutations

### Testing

- Unit tests for all services & providers
- Mock dependencies (no real DB/API in tests)
- Minimum 5 tests per service
- All tests pass before commit

## Phases

### Phase 1 ✅

- Manual entry of kilometers
- Dashboard with: total km, remaining km, weeks left, weekly average

### Phase 1.5 ✅

- GoalsListScreen (main screen - list active goals)
- RunHistoryScreen (list all runs)
- Goal creation with name + activity type
- Goal sorting by deadline

### Phase 2 ✅

- **Health Connect integration**
- Auto-sync Strava runs daily
- Deduplication by UUID
- Filter day-only imports

### Phase 3 (In Progress)

- Goal history (completed/failed goals with status) ✅
- Modify/delete individual runs
- Modify goal (date only, not km)
- Weekly notifications
- Charts & visualization (fl_chart)

### Phase 4+ (Future)

- Dark mode
- Multiple languages
- Achievements/badges
- Share progress

## Key Commands

- `flutter pub get` — install dependencies
- `flutter analyze` — run linter
- `flutter test` — run unit tests
- `dart run build_runner build` — regenerate Freezed/JsonSerializable
- `flutter run` — launch on Pixel 7
- `flutter clean` — reset build cache

## Git Workflow

- Feature branches: `feat/feature-name`
- PR descriptions in English (feature/bug-fix/testing sections)
- Merge after validation
- Keep main branch stable

## Important Notes

- Strava OAuth2 not used — Health Connect API instead (free, Android-native)
- LastSyncDate in memory only (no persistence yet) — TODO: add dédoublonnage by UUID
- Edit/Delete runs available (no longer from Strava only)
- MainActivity extends FlutterFragmentActivity (required for Health Connect)
