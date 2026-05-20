# REFINED PRD — edhitha_team2027_swarm_interface
**Version:** 2.0 (Agent-Executable)
**Target Agent:** Cursor / Windsurf (Antigravity)
**Execution Mode:** One-shot, Phase 1 complete

---

## 0. AGENT CONTRACT

You are a senior Flutter/Dart engineer. Your job is to produce a **fully runnable Flutter project** for Phase 1 of this application. When you are done, running `flutter run` must launch the app with zero errors. Do not stub, skip, or leave TODOs. Every file you create must be complete and production-ready.

Work **top-down** in this exact order:
1. Project scaffold & `pubspec.yaml`
2. Platform permission configuration
3. Design system / theme
4. State management + providers
5. Services (ASR + Intent Parser)
6. UI screens
7. Unit tests

Do not proceed to a later step until the current one compiles cleanly.

---

## 1. PROJECT IDENTITY

| Field | Value |
|---|---|
| **App Name** | Swarm Interface |
| **Package Name** | `com.edhitha.team2027.swarm_interface` |
| **Flutter SDK** | `>=3.22.0 <4.0.0` |
| **Dart SDK** | `>=3.4.0 <4.0.0` |
| **Min Android SDK** | 24 |
| **Min iOS Version** | 14.0 |

---

## 2. HARD CONSTRAINTS (NON-NEGOTIABLE)

- **Zero internet.** No Firebase, no Google Cloud STT, no REST calls of any kind.
- **Offline ASR only.** Use `speech_to_text: ^7.0.0` with `listenOptions: SpeechListenOptions(partialResults: true, onDevice: true)`. The `onDevice: true` flag forces on-device processing.
- **State management:** Riverpod (`flutter_riverpod: ^2.5.1` + `riverpod_annotation: ^2.3.5`). Use `@riverpod` codegen.
- **No `setState` outside of `ConsumerStatefulWidget` lifecycle methods.** All business logic lives in Notifiers.
- All colors, spacings, and text styles must come from the central `AppTheme` — no hardcoded values anywhere else.

---

## 3. EXACT DEPENDENCY MANIFEST

Paste this verbatim into `pubspec.yaml`:

```yaml
name: edhitha_team2027_swarm_interface
description: Offline swarm drone command interface for IARC Mission 10.
publish_to: none
version: 1.0.0+1

environment:
  sdk: ">=3.4.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  speech_to_text: ^7.0.0
  permission_handler: ^11.3.1
  google_fonts: ^6.2.1
  gap: ^3.0.1
  flutter_animate: ^4.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.3
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.13

flutter:
  uses-material-design: true
```

---

## 4. COMPLETE FILE TREE

Create **every** file listed. No file may be omitted.

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   │   ├── app_theme.dart          # Full ThemeData + color tokens
│   │   └── app_text_styles.dart    # All TextStyle constants
│   └── constants/
│       └── command_ids.dart        # CMD_* enum + trigger words map
├── features/
│   └── voice_command/
│       ├── data/
│       │   └── asr_service.dart    # speech_to_text wrapper
│       ├── domain/
│       │   └── intent_parser.dart  # Raw string → CommandId mapping
│       ├── presentation/
│       │   ├── providers/
│       │   │   ├── asr_provider.dart        # ASR state notifier
│       │   │   └── intent_provider.dart     # Derived intent state
│       │   ├── screens/
│       │   │   └── voice_debug_screen.dart  # Main Phase 1 UI
│       │   └── widgets/
│       │       ├── mic_toggle_button.dart
│       │       ├── transcription_stream_card.dart
│       │       └── intent_display_card.dart
└── test/
    └── intent_parser_test.dart
```

---

## 5. DESIGN SYSTEM

**Palette (exact hex values):**

| Token | Hex | Usage |
|---|---|---|
| `colorBackground` | `#F7F8FA` | All screen backgrounds |
| `colorSurface` | `#ECEEF2` | Cards, containers |
| `colorSurfaceDark` | `#D5D9E0` | Dividers, borders |
| `colorAccent` | `#2563EB` | Active mic, safe paths, CTAs |
| `colorAccentLight` | `#EFF4FF` | Active mic background glow |
| `colorSuccess` | `#16A34A` | Valid CMD recognized |
| `colorWarning` | `#D97706` | Partial/ambiguous match |
| `colorError` | `#DC2626` | No match / mic error |
| `colorTextPrimary` | `#111827` | Headlines, CMD labels |
| `colorTextSecondary` | `#6B7280` | Captions, metadata |

**Typography:** Use `google_fonts.GoogleFonts.dmSans()` as the base font family. Do not use the default Roboto.

**Spacing:** Use a base-8 grid. Define constants: `spacing4 = 4.0`, `spacing8 = 8.0`, `spacing16 = 16.0`, `spacing24 = 24.0`, `spacing32 = 32.0`, `spacing48 = 48.0`.

**Border Radius:** Cards use `BorderRadius.circular(16)`. Buttons use `BorderRadius.circular(12)`. Mic button uses `BorderRadius.circular(9999)` (full circle).

---

## 6. COMMAND ID SPECIFICATION

Define as a Dart `enum` in `lib/core/constants/command_ids.dart`:

```dart
enum CommandId {
  cmdLaunch,
  cmdHover,
  cmdOrbit,
  cmdLand,
  cmdDirN,   // North / Forward
  cmdDirL,   // Search Left
  cmdDirR,   // Search Right
  cmdHalt,
  unknown,
}
```

### Trigger Word Map (implement in `IntentParser`):

| CommandId | Trigger Keywords (case-insensitive, partial match OK) |
|---|---|
| `cmdLaunch` | `launch`, `takeoff`, `take off`, `liftoff`, `lift off`, `begin launch` |
| `cmdHover` | `hover`, `hold position`, `stay` |
| `cmdOrbit` | `orbit`, `circle`, `rotate around` |
| `cmdLand` | `land`, `descend`, `set down`, `touch down` |
| `cmdDirN` | `advance`, `forward`, `move forward`, `go forward`, `proceed` |
| `cmdDirL` | `search left`, `go left`, `move left`, `left` |
| `cmdDirR` | `search right`, `go right`, `move right`, `right` |
| `cmdHalt` | `stop`, `halt`, `hold`, `freeze`, `abort` |

### IntentParser Contract:

```dart
// Signature — implement this exactly
CommandId parse(String rawTranscript);
```

- Normalize: lowercase, strip punctuation, trim whitespace.
- Match by checking if the normalized string **contains** any trigger keyword.
- If multiple matches: return the **last** matched keyword's command (most recent intent wins).
- If zero matches: return `CommandId.unknown`.
- This class must be a **pure Dart class** with no Flutter imports — fully unit-testable.

---

## 7. ASR SERVICE SPECIFICATION

File: `lib/features/voice_command/data/asr_service.dart`

```dart
// Must expose these and nothing else:
class AsrService {
  Future<bool> initialize();          // Request mic permission + init speech_to_text
  Future<void> startListening({required void Function(String partial) onResult});
  Future<void> stopListening();
  Stream<String> get transcriptStream; // Broadcasts partial results
  bool get isAvailable;
  bool get isListening;
}
```

- Use `permission_handler` to request `Permission.microphone` before init.
- If permission denied: set an error state via a `StateProvider<String?>` named `asrErrorProvider`.
- Pass `SpeechListenOptions(onDevice: true, partialResults: true, listenMode: ListenMode.dictation)` to every `startListening` call.
- On `speech_to_text` error callback: broadcast the error string to `asrErrorProvider`.

---

## 8. RIVERPOD PROVIDER ARCHITECTURE

### `asrProvider` (StateNotifier)
- State class: `AsrState { bool isInitialized, bool isListening, String transcript, String? error }`
- Methods: `initialize()`, `toggleListening()`
- On `toggleListening`: if not listening → call `AsrService.startListening`, update `isListening = true`. If listening → `stopListening`, `isListening = false`.
- Partial results from ASR → update `transcript` field.

### `intentProvider` (Provider, derived)
- Watches `asrProvider.select((s) => s.transcript)`
- Returns `IntentParser().parse(transcript)` — recomputes on every transcript change.
- This is a **read-only derived provider**, no Notifier needed.

---

## 9. VOICE DEBUG SCREEN — UI SPECIFICATION

File: `lib/features/voice_command/presentation/screens/voice_debug_screen.dart`

**Layout (top to bottom, all inside a `SafeArea` + `Scaffold` with `colorBackground`):**

```
┌─────────────────────────────────────┐
│  [AppBar] "SWARM INTERFACE"  v1.0   │  ← Title left, version right, no elevation
│                                     │
│  ┌─────────────────────────────┐   │
│  │  INTENT DISPLAY CARD        │   │  ← Large card, top half
│  │  [CMD Label]  [CMD Icon]    │   │  ← e.g. "CMD_LAUNCH" + rocket icon
│  │  [Status Chip: RECOGNIZED]  │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  TRANSCRIPTION STREAM CARD  │   │  ← Live scrolling text
│  │  "advance to grid 4..."     │   │
│  └─────────────────────────────┘   │
│                                     │
│         [MIC TOGGLE BUTTON]         │  ← Center bottom, 80×80 circle
│    "TAP TO SPEAK" / "LISTENING..."  │
└─────────────────────────────────────┘
```

**Intent Display Card behavior:**
- Background: `colorSurface`
- When `CommandId.unknown`: show grey chip labeled "AWAITING INPUT"
- When valid command: show `colorSuccess` chip, bold CMD label, relevant icon from `Icons.*`
- Animate card color change with `flutter_animate` (fade + scale, 200ms)

**Mic Toggle Button behavior:**
- Idle: `colorSurface` background, `colorAccent` mic icon
- Active/Listening: `colorAccentLight` background, pulsing `colorAccent` border (animate with `flutter_animate` repeating shimmer)
- If `asrState.error != null`: show `colorError` background, display error snackbar

**Transcription Stream Card behavior:**
- Shows last 5 partial transcript lines in a scrollable list
- New entries slide in from the bottom (`flutter_animate` slide + fade)
- Each line: timestamp on left (HH:mm:ss), transcript text on right
- Background: `colorSurface`

---

## 10. CMD → ICON MAPPING

Use these Material Icons for the Intent Display Card:

| CommandId | Icon | Label |
|---|---|---|
| `cmdLaunch` | `Icons.rocket_launch` | `CMD_LAUNCH` |
| `cmdHover` | `Icons.airline_stops` | `CMD_HOVER` |
| `cmdOrbit` | `Icons.rotate_right` | `CMD_ORBIT` |
| `cmdLand` | `Icons.flight_land` | `CMD_LAND` |
| `cmdDirN` | `Icons.arrow_upward` | `CMD_DIR_N` |
| `cmdDirL` | `Icons.arrow_back` | `CMD_DIR_L` |
| `cmdDirR` | `Icons.arrow_forward` | `CMD_DIR_R` |
| `cmdHalt` | `Icons.pan_tool` | `CMD_HALT` |
| `unknown` | `Icons.mic_none` | `AWAITING INPUT` |

---

## 11. PLATFORM CONFIGURATION

### Android — `android/app/src/main/AndroidManifest.xml`

Add inside `<manifest>` tag, **before** `<application>`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE"/>
```

### iOS — `ios/Runner/Info.plist`

Add inside `<dict>`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Swarm Interface requires microphone access for voice command recognition.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Swarm Interface uses on-device speech recognition to map voice commands to drone controls.</string>
```

### Android `build.gradle` — minimum SDK:
```gradle
minSdkVersion 24
```

---

## 12. UNIT TEST SPECIFICATION

File: `test/intent_parser_test.dart`

Write tests covering **all** of the following cases. Each must `expect` a specific `CommandId`:

| Input String | Expected |
|---|---|
| `"Launch"` | `cmdLaunch` |
| `"begin launch sequence"` | `cmdLaunch` |
| `"Take off now"` | `cmdLaunch` |
| `"Hover in place"` | `cmdHover` |
| `"Circle the target"` | `cmdOrbit` |
| `"orbit"` | `cmdOrbit` |
| `"Land immediately"` | `cmdLand` |
| `"touch down"` | `cmdLand` |
| `"Advance to sector 4"` | `cmdDirN` |
| `"Move forward 10 meters"` | `cmdDirN` |
| `"Search Left quadrant"` | `cmdDirL` |
| `"Search Right please"` | `cmdDirR` |
| `"Stop all drones"` | `cmdHalt` |
| `"abort abort"` | `cmdHalt` |
| `"hello world"` | `unknown` |
| `""` (empty string) | `unknown` |
| `"  "` (whitespace) | `unknown` |
| `"LAUNCH"` (all caps) | `cmdLaunch` |

---

## 13. CODE QUALITY REQUIREMENTS

- All public classes and methods must have a one-line doc comment (`///`).
- Run `flutter analyze` — zero warnings, zero errors.
- Run `dart format .` — fully formatted.
- No `print()` statements — use `debugPrint()` with a `[SwarmApp]` prefix.
- No `dynamic` types anywhere.
- No unused imports.

---

## 14. WHAT NOT TO BUILD (PHASE 2–4 — DEFER COMPLETELY)

Do **not** create any of the following yet. Leave zero stubs or placeholder files for them:
- UDP/networking code
- Map/canvas rendering
- CSV/JSON export
- Database / sqflite
- Any second screen beyond `VoiceDebugScreen`

---

## 15. DEFINITION OF DONE

Phase 1 is complete when:

- [ ] `flutter pub get` succeeds with zero resolution errors.
- [ ] `flutter analyze` returns `No issues found!`
- [ ] `flutter test` passes all 18 intent parser tests.
- [ ] App launches on Android emulator (API 24+) without crash.
- [ ] Mic permission dialog appears on first launch.
- [ ] Tapping mic button starts listening; recognized words stream into the transcription card in real-time.
- [ ] Saying "Launch" → Intent card shows `CMD_LAUNCH` with `Icons.rocket_launch`.
- [ ] Saying "Stop" → Intent card shows `CMD_HALT` with `Icons.pan_tool`.
- [ ] Saying an unknown phrase → card shows "AWAITING INPUT" in grey.

---

# CURSOR / WINDSURF EXECUTION PROMPT

> Copy everything below this line and paste it as your first message to Cursor or Windsurf.

---

```
You are a senior Flutter/Dart engineer. I need you to build a complete, fully runnable Flutter application called `edhitha_team2027_swarm_interface` from scratch, following the PRD I am about to give you. 

**CRITICAL RULES — READ BEFORE STARTING:**
1. Build everything in one pass. No stubs, no TODOs, no placeholder functions.
2. Every file must be complete, compilable Dart/Flutter code.
3. Work in this exact order: pubspec.yaml → platform configs → theme → constants → services → providers → widgets → screens → tests.
4. Do not move to the next file until the current one is complete.
5. After generating all files, output a final checklist confirming: (a) flutter pub get will succeed, (b) flutter analyze is clean, (c) all 18 unit tests will pass.

**SCOPE:** Implement Phase 1 ONLY. Do not create any code, files, or stubs for UDP networking, maps, or data export.

**THE PRD:**

[PASTE THE FULL REFINED PRD ABOVE HERE]

Begin now. Start with `pubspec.yaml`, then `android/app/src/main/AndroidManifest.xml`, then `ios/Runner/Info.plist`, then work through the file tree in `lib/` top-down. Output each complete file with its full path as a header. Do not stop until all files in Section 4's file tree are generated and the 18 unit tests in Section 12 are written.
```
