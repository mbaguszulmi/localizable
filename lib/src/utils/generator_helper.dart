import 'package:localizable/src/utils/regex_utils.dart';

class AbstractLocalizationGeneratorHelper {
  static String getterStringDeclaration(String defaultLocale, String stringKey, String data) {
    String declaration;
    if (isStringUsingPlaceholders(data)) {
      final placeholderMatches = getMatchDataPlaceholders(data);
      final methodArgs = placeholderMatches.map((match) => '${match.group(2)}').toList();
      final methodArgsString = methodArgs.map((arg) => "required String $arg").join(', ');
      declaration = '''
        String $stringKey({$methodArgsString});
      ''';
    } else {
      declaration = 'String get $stringKey;';
    }

    return '''
        /// Returns the translation of the string with key **'$stringKey'**.
        /// 
        /// In $defaultLocale, this messages translate to:
        /// **'$data'**
        $declaration
      ''';
  }

  static String getterStringMethod(String defaultLocale, String stringKey, String data) {
    String declaration;
    if (isStringUsingPlaceholders(data)) {
      final placeholderMatches = getMatchDataPlaceholders(data);
      final methodArgs = placeholderMatches.map((match) => '${match.group(2)}').toList();
      final methodArgsString = methodArgs.map((arg) => "required String $arg").join(', ');

      for (String arg in methodArgs) {
        data = data.replaceAll('{$arg}', '\$$arg');
      }

      declaration = '''
        String $stringKey({$methodArgsString}) {
          return '$data';
        }
      ''';
    } else {
      declaration = 'String get $stringKey => \'$data\';';
    }

    return '''
        @override
        $declaration
      ''';
  }
}

