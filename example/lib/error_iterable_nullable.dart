import 'package:args_macro/args_macro.dart';

@Args()
class MyArgs {
  final List<String>? nullableStringList;
  final Set<String>? nullableStringSet;
}

void main() {}
