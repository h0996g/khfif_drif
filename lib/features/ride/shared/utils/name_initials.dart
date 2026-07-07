/// Builds up-to-two-letter initials from a display name.
///
/// `"Yacine Benali" → "YB"`, `"Sami" → "S"`, `"" → "·"`. Shared by the avatars
/// on the driver history card and the passenger offer card.
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  String initial(String part) => part.isNotEmpty ? part[0] : '';
  if (parts.isEmpty || parts.first.isEmpty) return '·';
  if (parts.length == 1) return initial(parts.first).toUpperCase();
  return '${initial(parts.first)}${initial(parts[1])}'.toUpperCase();
}
