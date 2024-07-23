/// Like [Future.wait] but for a [Map].
Future<Map<K, V>> waitMap<K, V>(Map<K, Future<V>> futures) async {
  final keys = futures.keys.toList(growable: false);
  final values = await Future.wait(futures.values);
  final n = futures.length;

  return {
    for (int i = 0; i < n; i++) keys[i]: values[i],
  };
}
