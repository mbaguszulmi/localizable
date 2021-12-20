import 'package:build/build.dart';
import 'package:localizable/src/generators/localization_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder generateLocalizations(BuilderOptions options) =>
    SharedPartBuilder([LocalizationGenerator()], "localization_generator");
