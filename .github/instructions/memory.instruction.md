---
applyTo: '**'
---

# User Memory - Kenwa Salud y Armonía

## Project Context
- **App**: Kenwa - Health & Wellness Flutter app
- **Current Phase**: Configuration feature refinement and validation
- **Architecture**: Clean Architecture (data/domain/presentation layers)
- **State Management**: StatefulWidget controllers
- **Storage**: SharedPreferences for configuration persistence

## Recent Work Session
- **Focus**: Input validation for time picker (horario_input.dart)
- **Issue**: User could enter invalid times like "-5:00" or hours > 23
- **Solution Implemented**:
  1. Added `FilteringTextInputFormatter.digitsOnly` to TextField to block negative signs
  2. Enhanced validation logic to check for parsed values < 0 and clamp to 0
  3. Maintained existing maxValue validation (0-23 for hours, 0-59 for minutes)
  4. Reformatted input automatically when out of range

## Validation Rules Enforced
- **Hours (Hora)**: 0-23 (00:00 to 23:59 military time)
- **Minutes (Minuto)**: 0-59
- **Negative numbers**: Ignored via onChanged logic (int.tryParse returns null for "-5")
- **Overflow values**: Auto-clamped to maxValue when parsed
- **User feedback**: Real-time adjustment with corrected display
- **Editable**: User can freely type and edit; validation happens on parse, not on input filtering

## Color Palette (Active)
- **Primary**: #2E8E57 (Kenwa green) - action buttons, interactive elements
- **Foreground**: #413030 (dark brown) - text, borders, neutral UI
- **Background**: #FCFFFF (off-white) - input fields, surfaces

## Code Quality Standards
- Follow existing Flutter/Dart conventions
- Use FilteringTextInputFormatter for input validation
- Keep validation logic in onChanged callback with early returns
- Update TextField display immediately when value is corrected

## Dependencies Used
- flutter/services.dart - for FilteringTextInputFormatter
- go_router - navigation
- shared_preferences - local storage
- flutter_local_notifications: ^19.5.0 - notification management and permissions

## Notification System Implementation
- **Service**: `lib/services/notification_service.dart` - Singleton NotificationService class
- **Features**:
  - Initialize notifications on app startup
  - Request notification permissions (Android 13+, iOS, macOS)
  - Check notification status
  - Show simple notifications
  - Schedule periodic notifications
  - Cancel notifications
- **Integration**: ConfiguracionInicialPage Switch now calls requestNotificationPermission() when enabled
- **Platforms**: Android, iOS, macOS, Linux, Windows supported via flutter_local_notifications
- **Android Setup Complete**:
  - AndroidManifest.xml: Added POST_NOTIFICATIONS, VIBRATE, RECEIVE_BOOT_COMPLETED, SCHEDULE_EXACT_ALARM permissions
  - AndroidManifest.xml: Added receivers for ScheduledNotificationReceiver, ScheduledNotificationBootReceiver, ActionBroadcastReceiver
  - build.gradle.kts: Enabled core library desugaring, set compileSdk to 35
  - build.gradle.kts: Added desugar_jdk_libs:2.1.4 dependency
  - Created app_icon.xml drawable resource for notification icon

## Known Implementation Patterns
- Modal dialogs use neutral background with foreground accents
- Time inputs use 2-digit padding (padLeft(2, '0'))
- All time values stored/displayed in 24-hour format
