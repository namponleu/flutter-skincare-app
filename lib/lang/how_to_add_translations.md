# How to Add Translations to Any Screen

## 1. Import the Language System
```dart
import '../lang/index.dart';
```

## 2. Wrap Your Screen with Consumer
```dart
@override
Widget build(BuildContext context) {
  return Consumer<LanguageService>(
    builder: (context, languageService, child) {
      return Scaffold(
        // Your screen content here
      );
    },
  );
}
```

## 3. Replace Hardcoded Text with Translations
```dart
// Before
Text('Hello World')

// After
Text(T.get(TranslationKeys.helloWorld))
```

## 4. Add Translation Keys to TranslationKeys Class
```dart
// In lib/lang/translations.dart
class TranslationKeys {
  // ... existing keys ...
  static const String helloWorld = 'hello_world';
}
```

## 5. Add Translations to Language Model
```dart
// In lib/lang/language_model.dart
Language(
  code: 'en',
  name: 'English',
  nativeName: 'English',
  flag: '🇺🇸',
  translations: {
    // ... existing translations ...
    'hello_world': 'Hello World',
  },
),
Language(
  code: 'kh',
  name: 'Khmer',
  nativeName: 'ខ្មែរ',
  flag: '🇰🇭',
  translations: {
    // ... existing translations ...
    'hello_world': 'សួស្តីពិភពលោក',
  },
),
```

## 6. Benefits
- ✅ **Automatic language switching** - UI updates immediately
- ✅ **Persistent language choice** - Saved across app restarts
- ✅ **Easy to add new languages** - Just add to the array
- ✅ **Type-safe translations** - Compile-time error checking
- ✅ **Centralized management** - All translations in one place

## 7. Example: Adding to Home Screen
```dart
// In home_screen.dart
import '../lang/index.dart';

class HomeScreen extends StatefulWidget {
  // ... existing code ...
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(T.get(TranslationKeys.home)),
          ),
          body: Column(
            children: [
              Text(T.get(TranslationKeys.welcomeMessage)),
              // ... rest of your UI
            ],
          ),
        );
      },
    );
  }
}
```

## 8. Translation Keys for Common UI Elements
```dart
// Common UI elements you might want to translate
static const String home = 'home';
static const String welcomeMessage = 'welcome_message';
static const String loading = 'loading';
static const String error = 'error';
static const String success = 'success';
static const String cancel = 'cancel';
static const String confirm = 'confirm';
static const String save = 'save';
static const String delete = 'delete';
static const String edit = 'edit';
static const String add = 'add';
static const String search = 'search';
static const String filter = 'filter';
static const String sort = 'sort';
static const String refresh = 'refresh';
static const String retry = 'retry';
static const String close = 'close';
static const String next = 'next';
static const String previous = 'previous';
static const String done = 'done';
```

## 9. Testing Your Translations
1. **Change language** in profile screen
2. **Navigate to your screen** - text should update immediately
3. **Restart app** - language choice should persist
4. **Check both languages** - ensure all text is translated

## 10. Best Practices
- ✅ **Use descriptive key names** - `userProfile` not `up`
- ✅ **Group related keys** - `profile_edit`, `profile_save`, `profile_delete`
- ✅ **Keep translations concise** - avoid very long text
- ✅ **Test with different text lengths** - some languages are longer
- ✅ **Use placeholders for dynamic content** - `welcome_user: 'Welcome, {name}!'`

That's it! Your screen now supports multiple languages automatically! 🎉 