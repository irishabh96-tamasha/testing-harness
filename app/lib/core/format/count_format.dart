/// Formats a count using Indian-style abbreviations (K / L / Cr) to match the
/// design (e.g. 24000 → "24K", 140000 → "1.4L").
String formatCount(int n) {
  if (n >= 10000000) {
    return '${_trim(n / 10000000)}Cr';
  }
  if (n >= 100000) {
    return '${_trim(n / 100000)}L';
  }
  if (n >= 1000) {
    return '${_trim(n / 1000)}K';
  }
  return '$n';
}

String _trim(double v) {
  // One decimal, but drop a trailing ".0".
  final String s = v.toStringAsFixed(1);
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}
