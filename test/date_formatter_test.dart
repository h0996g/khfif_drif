import 'package:flutter_test/flutter_test.dart';
import 'package:khfif_drif/features/ride/shared/utils/date_formatter.dart';

void main() {
  group('formatRideDate', () {
    test('formats as dd/MM/yyyy', () {
      expect(formatRideDate('2026-08-22T14:05:00Z'), '22/08/2026');
    });

    test('returns empty string for unparseable input', () {
      expect(formatRideDate('not-a-date'), '');
    });
  });

  group('formatRideDateTime', () {
    test('formats a local (offset-less) timestamp as dd/MM/yyyy · HH:mm', () {
      // No UTC suffix → components are local, deterministic on any machine.
      expect(formatRideDateTime('2026-08-22T14:05:00'), '22/08/2026 · 14:05');
    });

    test('converts UTC input to local time', () {
      final iso = '2026-08-22T14:05:00Z';
      final expected = () {
        final local = DateTime.parse(iso).toLocal();
        final day = local.day.toString().padLeft(2, '0');
        final month = local.month.toString().padLeft(2, '0');
        final hour = local.hour.toString().padLeft(2, '0');
        final minute = local.minute.toString().padLeft(2, '0');
        return '$day/$month/${local.year} · $hour:$minute';
      }();
      expect(formatRideDateTime(iso), expected);
    });

    test('returns empty string for unparseable input', () {
      expect(formatRideDateTime(''), '');
      expect(formatRideDateTime('not-a-date'), '');
    });
  });
}
