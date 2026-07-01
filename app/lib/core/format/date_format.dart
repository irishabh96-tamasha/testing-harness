const List<String> _months = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Formats a date like "15 June, 2026".
String formatLongDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1]}, ${d.year}';
