# Activity Tracker App

## Stack

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Local Storage:** SQLite (sqflite)
- **External API:** Strava OAuth2
- **Target:** Android (Pixel 7)

## Project Structure

- lib/
  - models/ # Data classes
  - screens/ # UI screens
  - services/ # API & DB logic
  - providers/ # Riverpod notifiers
  - main.dart

## Architecture Rules

- Use Riverpod AsyncNotifier pattern for async operations
- SQLite for persistence, JSON serialization for models
- Feature-first approach as complexity grows

## Key Commands

- `flutter pub get`
- `flutter analyze`
- `flutter run` (always target Pixel 7)
- `flutter test`

## Phase 1 MVP

- Manual entry of kilometers
- Dashboard with: total, remaining, weeks left, weekly average needed

## Code Standards

### Structure

- One class/service = one file
- lib/services/ for business logic
- lib/providers/ for Riverpod notifiers
- lib/models/ for data classes
- Avoid files > 300 lines

### Dart Conventions

- Names: camelCase for variables/methods, PascalCase for classes
- Always explicitly type return types
- Const constructors when possible
- Null safety: avoid !, prefer ??

### Architecture

- Separation of concerns: models ≠ services ≠ providers
- Services: business logic + persistence
- Providers: state management and service exposure
- No complex UI logic outside screens

### Riverpod Best Practices

- Use AsyncNotifier for async operations
- No mutable global state
- Explicit dependencies between providers (via .select())
