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

## Known Implementation Patterns
- Modal dialogs use neutral background with foreground accents
- Time inputs use 2-digit padding (padLeft(2, '0'))
- All time values stored/displayed in 24-hour format
