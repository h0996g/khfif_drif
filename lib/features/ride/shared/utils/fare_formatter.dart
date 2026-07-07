/// Formats a fare amount (whole DZD) with thin-space thousands grouping.
///
/// `1200 → "1 200"`, `-50 → "- 50"`. Used by every card that shows a fare so
/// the grouping can't drift between surfaces.
String formatFare(int amount) {
  final negative = amount < 0;
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return negative ? '-$buffer' : buffer.toString();
}
