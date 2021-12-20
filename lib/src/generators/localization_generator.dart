import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:localizable/src/utils/generator_helper.dart';
import 'package:localizable/src/utils/model_visitor.dart';
import 'package:localizable_annotation/localizable_annotation.dart';
import 'package:source_gen/source_gen.dart';

import '../utils/string_extensions.dart';

class LocalizationGenerator extends GeneratorForAnnotation<Localizable> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final visitor = ModelVisitor();
    if (element is ClassElement) {
      element.accept(visitor);
    }
    element.visitChildren(visitor);

    final localizableClassNameData = annotation.read("className");
    String localizableClassName;
    if (localizableClassNameData.isNull) {
      localizableClassName = "{element.name}Localization";
    } else {
      localizableClassName = localizableClassNameData.stringValue;
    }

    final translations =
        visitor.fieldsValue['translations'] as Map<String, Map<String, String>>;

    // supported locales
    List<String> supportedLocales = [];
    supportedLocales.addAll(translations.keys);

    // default locale
    String defaultLocale;
    if (visitor.fieldsValue['defaultLocale'] is String) {
      defaultLocale = visitor.fieldsValue['defaultLocale'] as String;
    } else {
      throw InvalidGenerationSourceError(
        'The defaultLocale field must be a String',
        element: element,
      );
    }

    String defaultTranslationClassName = "$localizableClassName${defaultLocale.toCapitalized()}";

    // string keys
    Map<String, String> defaultLocaleData = translations[defaultLocale]!;
    List<String> stringKeys = defaultLocaleData.keys.toList();

    final classBuffer = StringBuffer();
    
    String fileName = "";
    element.location!.components.forEach((component) {
      if (component.endsWith('.dart') && fileName.isEmpty) {
        fileName = component.split('/').last;
        return;
      }
    });

    classBuffer.writeln('''
      // Please import this import block below in $fileName

      // import 'dart:async';

      // import 'package:flutter/foundation.dart';
      // import 'package:flutter/widgets.dart';
      // import 'package:flutter_localizations/flutter_localizations.dart';
      // import 'package:intl/intl.dart';

      /// Callers can lookup localized strings with an instance of $localizableClassName returned
      /// by `$localizableClassName.of(context)`.
      ///
      /// Applications need to include `$localizableClassName.delegate()` in their app's
      /// localizationDelegates list, and the locales they support in the app's
      /// supportedLocales list. For example:
      ///
      /// ```
      ///
      /// return MaterialApp(
      ///   localizationsDelegates: $localizableClassName.localizationsDelegates,
      ///   supportedLocales: $localizableClassName.supportedLocales,
      ///   home: MyApplicationHome(),
      /// );
      /// ```
      ///
      /// ## Update pubspec.yaml
      ///
      /// Please make sure to update your pubspec.yaml to include the following
      /// packages:
      ///
      /// ```
      /// dependencies:
      ///   # Internationalization support.
      ///   flutter_localizations:
      ///     sdk: flutter
      ///   intl: any # Use the pinned version from flutter_localizations
      ///
      ///   # rest of dependencies
      /// ```
      ///
      /// ## iOS Applications
      ///
      /// iOS applications define key application metadata, including supported
      /// locales, in an Info.plist file that is built into the application bundle.
      /// To configure the locales supported by your app, you’ll need to edit this
      /// file.
      ///
      /// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
      /// Then, in the Project Navigator, open the Info.plist file under the Runner
      /// project’s Runner folder.
      ///
      /// Next, select the Information Property List item, select Add Item from the
      /// Editor menu, then select Localizations from the pop-up menu.
      ///
      /// Select and expand the newly-created Localizations item then, for each
      /// locale your application supports, add a new item and select the locale
      /// you wish to add from the pop-up menu in the Value field. This list should
      /// be consistent with the languages listed in the $localizableClassName.supportedLocales
      /// property.
    ''');
    classBuffer.writeln("abstract class $localizableClassName {");
    classBuffer.writeln(
        "$localizableClassName(String locale) : localeName = Intl.canonicalizedLocale(locale.toString());");
    classBuffer.writeln("final String localeName;");

    classBuffer.writeln('''
      static $localizableClassName? of(BuildContext context) {
        return Localizations.of<$localizableClassName>(context, $localizableClassName);
      }
    ''');

    classBuffer.writeln(
        'static const LocalizationsDelegate<$localizableClassName> delegate = _${localizableClassName}Delegate();');

    classBuffer.writeln('''
      /// A list of this localizations delegate along with the default localizations
      /// delegates.
      ///
      /// Returns a list of localizations delegates containing this delegate along with
      /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
      /// and GlobalWidgetsLocalizations.delegate.
      ///
      /// Additional delegates can be added by appending to this list in
      /// MaterialApp. This list does not have to be used at all if a custom list
      /// of delegates is preferred or required.
      static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];
    ''');

    classBuffer.writeln('''
      /// A list of this localizations delegate's supported locales.
      static const List<Locale> supportedLocales = <Locale>[
    ''');

    for (final locale in supportedLocales) {
      classBuffer.writeln("Locale('$locale'),");
    }

    classBuffer.writeln('];');

    for (final stringKey in stringKeys) {
      String stringData = defaultLocaleData[stringKey]!;
      classBuffer.writeln(
          AbstractLocalizationGeneratorHelper.getterStringDeclaration(
              defaultLocale, stringKey, stringData));
    }

    classBuffer.writeln("}");

    // delegate class
    classBuffer.writeln(
        "class _${localizableClassName}Delegate extends LocalizationsDelegate<$localizableClassName> {");

    classBuffer.writeln("const _${localizableClassName}Delegate();");

    classBuffer.writeln('''
      @override
      Future<$localizableClassName> load(Locale locale) {
        return SynchronousFuture<$localizableClassName>(lookup$localizableClassName(locale));
      }
    ''');

    classBuffer.writeln('''
      @override
      bool isSupported(Locale locale) => <String>[${supportedLocales.map((locale) => "'$locale'").join(', ')}].contains(locale.languageCode);
    ''');

    classBuffer.writeln('''
      @override
      bool shouldReload(_${localizableClassName}Delegate old) => false;
    ''');

    classBuffer.writeln("}");

    // lookup localizations method
    classBuffer
        .writeln("$localizableClassName lookup$localizableClassName(Locale locale) {");

    classBuffer.writeln('''
      // Lookup logic when only language code is specified.
      switch (locale.languageCode) {
        ${supportedLocales.map((locale) => 'case "$locale": return $localizableClassName${locale.toCapitalized()}();').join('\n')}
      }

      debugPrint('Localization with languageCode \${locale.languageCode} is not supported. Fallback to default locale($defaultLocale).');
      return $defaultTranslationClassName();
    ''');

    classBuffer.writeln("}");

    for (final locale in supportedLocales) {
      final localeName = locale.toCapitalized();
      final translationData = translations[locale]!;
      final translationClassName = '$localizableClassName$localeName';

      
      generateTranslationClass(classBuffer, locale, translationClassName, localizableClassName, translationData);
    }


    return classBuffer.toString();
  }

  void generateTranslationClass(StringBuffer classBuffer, String locale, String translationClassName, String localizableClassName, Map<String, String> translationData) {
    classBuffer.writeln('''
      /// The translations for `$locale`.
      class $translationClassName extends $localizableClassName {
    ''');

    classBuffer.writeln('''
        $translationClassName([String locale = '$locale']) : super(locale);
    ''');

    for (final stringKey in translationData.keys) {
      final stringData = translationData[stringKey]!;
      classBuffer.writeln(
          AbstractLocalizationGeneratorHelper.getterStringMethod(
              locale, stringKey, stringData));
    }

    classBuffer.writeln("}");
  }
}
