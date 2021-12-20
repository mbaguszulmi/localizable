final placeholderRegex = RegExp(
  r'({([A-Za-z_]{1}[A-Za-z0-9_$]+)})',
  caseSensitive: false,
  multiLine: true,
);

bool isStringUsingPlaceholders(String data) {
  return placeholderRegex.hasMatch(data);
}

List<RegExpMatch> getMatchDataPlaceholders(String data) {
  return placeholderRegex.allMatches(data).toList();
}
