abstract final class RadioBrowserHosts {
  const RadioBrowserHosts._();

  static const String userAgent =
      'RadioFlow/1.0 (+https://github.com/mobile-pablo/radioflow)';

  static const List<String> mirrors = [
    'https://de1.api.radio-browser.info',
    'https://de2.api.radio-browser.info',
    'https://nl1.api.radio-browser.info',
    'https://at1.api.radio-browser.info',
  ];

  static String random() => (mirrors.toList()..shuffle()).first;

  static String nextAfter(String current) {
    final index = mirrors.indexOf(current);
    return mirrors[(index + 1) % mirrors.length];
  }
}
