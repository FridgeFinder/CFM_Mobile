String normalizeFridgeId(String? id) {
  if (id == null) return '';
  return id.trim().toLowerCase();
}

bool fridgeIdsMatch(String? a, String? b) {
  return normalizeFridgeId(a) == normalizeFridgeId(b);
}