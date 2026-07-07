/// Formats an ISO-8601 timestamp as `dd/MM/yyyy` (no `intl` dependency in the
/// project).
///
/// `"2026-07-07T12:30:00Z" → "07/07/2026"`, unparseable input → `""`. Shared by
/// the ride-history cards so the date rendering can't drift between surfaces.
String formatRideDate(String iso) {
  final date = DateTime.tryParse(iso);
  if (date == null) return '';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

/// Formats a `from`/`to` ride-history filter boundary as a UTC ISO-8601
/// date-time. `showDatePicker` returns a local, time-of-day-less [DateTime];
/// serializing it directly (`toIso8601String()`) omits the offset/`Z`
/// suffix the backend's date-time validator requires. Anchoring the chosen
/// calendar day to UTC midnight (or its last instant for [endOfDay]) avoids
/// that ambiguity and makes `to` inclusive of the whole day.
String toHistoryFilterDateTime(DateTime date, {bool endOfDay = false}) {
  final utcMidnight = DateTime.utc(date.year, date.month, date.day);
  final boundary = endOfDay
      ? utcMidnight.add(const Duration(
          hours: 23,
          minutes: 59,
          seconds: 59,
          milliseconds: 999,
        ))
      : utcMidnight;
  return boundary.toIso8601String();
}
