# localizable

Automatically generate Localization helpers with only annotating class with `@Localizable`.

## How to Install

<!-- Add [localizable_annotation](https://pub.dev/packages/localizable_annotation) to `dependencies`, 
`localizable` and `build_runner` to `dev_dependencies` -->

Add `dependencies` and `dev_dependencies` to your `pubspec.yaml`

```
dependencies:
  flutter_localizations: # Add this line
    sdk: flutter # Add this line
  intl: any # Add this line
  localizable_annotation: ^0.0.3 # Add this line

dev_dependencies:
  localizable: ^0.0.2 # Add this line
  build_runner: any # Add this line
```

Packages reference:

- [flutter_localizations](https://pub.dev/packages/flutter_localizations)
- [intl](https://pub.dev/packages/intl)
- [localizable_annotation](https://pub.dev/packages/localizable_annotation)
- [build_runner](https://pub.dev/packages/build_runner)

## Usage

Create a file (eg. `app_localization.dart`) containing `translations` class with `@Localizable` 
annotation to accommodate your localizations 
String as shown on [this example](https://pub.dev/packages/localizable_annotation/example).

```
import 'package:localizable_annotation/localizable_annotation.dart';

@Localizable(
  className: "AppLocalization",
)
class AppTranslations {
  static const Map<String, Map<String, String>> translations = {
    'en': {
      'title': 'Flutter Demo',
      'description': 'A Flutter Demo',
      'greetings': 'Hello {name}!',
    },
    'id': {
      'title': 'Demo Flutter',
      'description': 'Sebuah Demo Flutter',
      'greetings': 'Halo {name}!',
    },
  };

  static const String defaultLocale = 'en';
}
```

Then, at the same file add `part` directive above the `@Localizable` statement.
(Eg. `part 'app_localization.g.dart';`)

And then, to generate localizations class, run this on your command line 
(make sure working directory is your project directory).

```
flutter pub run build_runner build
```

Or if you want to automatically generate when files is changed, you can run this command.

```
flutter pub run build_runner build
```

Last, add this import block at the top of the file where your `translations` 
class (annotated with `@Localizable`) defined.

```
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
```

For more details, visit [this example](https://pub.dev/packages/localizable/example).
