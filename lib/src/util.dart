/// Like [Future.wait] but for a [Map].
Future<Map<K, V>> waitMap<K, V>(Map<K, Future<V>> futures) async {
  final keys = futures.keys.toList(growable: false);
  final values = await Future.wait(futures.values);
  final n = futures.length;

  return {
    for (int i = 0; i < n; i++) keys[i]: values[i],
  };
}

// ignore: public_member_api_docs
extension NullableMapExtension<K, V> on Map<K, V?> {
  /// Returns a copy of this with non-null keys.
  Map<K, V> whereNotNull() {
    return {
      for (final entry in entries)
        if (entry.value is V) entry.key: entry.value as V,
    };
  }
}
