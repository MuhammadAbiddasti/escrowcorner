# Language System Implementation

This document explains how to use the new dynamic language system implemented in the EscrowCorner app.

## Overview

The language system allows users to switch between different languages dynamically throughout the app. It fetches available languages from the `/api/getLanguages` API endpoint and provides a seamless way to change languages without restarting the app.

## Features

- **Dynamic Language Fetching**: Automatically fetches languages from the API
- **Persistent Language Selection**: Saves user's language preference locally
- **Real-time Language Switching**: Changes language instantly across the app
- **RTL Support**: Automatically handles right-to-left languages
- **Multiple UI Components**: Different language selector widgets for different use cases
- **Internationalization**: Built-in translation system using GetX

## API Endpoint

The system uses the following API endpoint:
```
GET /api/getLanguages
```

**Response Format:**
```json
{
    "success": true,
    "languages": [
        {
            "id": 1,
            "name": "English",
            "locale": "en",
            "created_at": "2025-05-20T05:37:46.000000Z",
            "updated_at": "2025-05-20T05:37:46.000000Z"
        },
        {
            "id": 2,
            "name": "French",
            "locale": "fr",
            "created_at": "2025-05-20T05:37:53.000000Z",
            "updated_at": "2025-05-20T05:37:53.000000Z"
        }
    ]
}
```

## Components

### 1. LanguageController

The main controller that manages all language-related functionality.

**Location**: `lib/view/controller/language_controller.dart`

**Key Methods:**
- `fetchLanguages()`: Fetches languages from API
- `changeLanguage(Language language)`: Changes the app language
- `getCurrentLanguageName()`: Gets current language name
- `getCurrentLanguageLocale()`: Gets current language locale
- `isCurrentLanguageRTL()`: Checks if current language is RTL

### 2. LanguageSelectorWidget

A flexible widget that can be configured for different use cases.

**Location**: `lib/widgets/language_selector/language_selector_widget.dart`

**Configuration Options:**
- `showAsDropdown`: Shows as a dropdown selector
- `showAsBottomSheet`: Shows as a bottom sheet trigger
- `backgroundColor`: Custom background color
- `textColor`: Custom text color
- `width` & `height`: Custom dimensions

### 3. QuickLanguageSwitcher

A pre-configured language switcher for app bars.

**Usage:**
```dart
actions: [
  QuickLanguageSwitcher(),
  // other actions...
],
```

### 4. DropdownLanguageSelector

A dropdown language selector for forms.

**Usage:**
```dart
DropdownLanguageSelector(
  width: double.infinity,
  height: 45,
  backgroundColor: Colors.transparent,
  textColor: Colors.black,
),
```

## Implementation in Screens

### Home Screen
- **File**: `lib/view/Home_Screens/screen_home.dart`
- **Usage**: Language switcher in app bar

### Services Screen
- **File**: `lib/view/Home_Screens/screen_services.dart`
- **Usage**: Language switcher in app bar

### Dashboard Screen
- **File**: `lib/view/screens/dashboard/screen_dashboard.dart`
- **Usage**: Language switcher in app bar

### Signup Screen
- **File**: `lib/view/screens/register/screen_signup.dart`
- **Usage**: Language selector in form + app bar

## Adding New Languages

### 1. Add Language to API
Ensure the new language is added to the `/api/getLanguages` endpoint.

### 2. Add Translations
Add translations for the new language in `lib/main.dart`:

```dart
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      // English translations
    },
    'fr': {
      // French translations
    },
    'es': {  // New language
      'welcome': 'Bienvenido',
      'home': 'Inicio',
      // ... more translations
    },
  };
}
```

### 3. Test Language Switching
Use the language demo screen to test the new language:
- Navigate to the demo screen
- Select the new language
- Verify all text is properly translated

## Using Translations in Code

### Basic Translation
```dart
Text('welcome'.tr)  // Uses current language
```

### With Parameters
```dart
Text('hello_user'.trParams({'name': 'John'}))
```

### Conditional Translation
```dart
Text(Get.locale?.languageCode == 'fr' ? 'Bonjour' : 'Hello')
```

## Language Demo Screen

A dedicated screen to test and demonstrate the language system.

**Location**: `lib/view/screens/demo/language_demo_screen.dart`

**Features:**
- Current language display
- Language selector dropdown
- Sample content in different languages
- Language information display
- Available languages list
- Interactive language switching

## Best Practices

### 1. Always Use Translation Keys
Instead of hardcoded text, use translation keys:
```dart
// ❌ Bad
Text('Welcome to our app')

// ✅ Good
Text('welcome_message'.tr)
```

### 2. Handle Missing Translations
Provide fallback text for missing translations:
```dart
Text('welcome_message'.tr ?? 'Welcome')
```

### 3. Test All Languages
When adding new features, ensure all supported languages have proper translations.

### 4. Use Consistent Key Naming
Follow a consistent naming convention for translation keys:
- Use snake_case
- Group related keys with prefixes
- Keep keys descriptive but concise

## Troubleshooting

### Language Not Changing
1. Check if `LanguageController` is properly registered
2. Verify API response format
3. Check console for error messages
4. Ensure translations are properly defined

### Missing Translations
1. Add missing keys to `AppTranslations` class
2. Check key spelling and case
3. Verify language locale matches API response

### RTL Issues
1. Check if language is properly detected as RTL
2. Verify `isCurrentLanguageRTL()` method
3. Test with known RTL languages (Arabic, Hebrew)

## Future Enhancements

- **Auto-detection**: Automatically detect user's preferred language
- **Language Packs**: Download language packs for offline use
- **Custom Translations**: Allow users to customize translations
- **Voice Support**: Text-to-speech in different languages
- **Regional Formats**: Date, time, and number formatting per locale

## Dependencies

The language system requires the following packages:
- `get`: For state management and internationalization
- `shared_preferences`: For persistent language storage
- `http`: For API communication

## Support

For issues or questions about the language system:
1. Check the console logs for error messages
2. Verify API endpoint is accessible
3. Test with the language demo screen
4. Review this documentation
