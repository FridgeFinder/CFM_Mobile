/// Recursively converts `Map<Object?, Object?>` to `Map<String, dynamic>`
///
/// This is needed because Firebase Realtime Database returns `Map<Object?, Object?>`
/// and nested objects need to be recursively converted to avoid type cast errors
/// when deserializing with fromJson methods.
///
/// Example:
/// ```dart
/// final snapshot = await database.child('users').child(userId).get();
/// final data = snapshot.value as Map<Object?, Object?>;
/// final converted = convertFirebaseMap(data);
/// final userProfile = UserProfile.fromJson(converted);
/// ```
Map<String, dynamic> convertFirebaseMap(Map<Object?, Object?> map) {
  final result = <String, dynamic>{};
  for (final entry in map.entries) {
    final key = entry.key.toString();
    final value = entry.value;

    if (value is Map<Object?, Object?>) {
      // Recursively convert nested maps
      result[key] = convertFirebaseMap(value);
    } else if (value is List) {
      // Convert lists (in case they contain maps)
      result[key] = value.map((item) {
        if (item is Map<Object?, Object?>) {
          return convertFirebaseMap(item);
        }
        return item;
      }).toList();
    } else {
      result[key] = value;
    }
  }
  return result;
}
