import 'package:args_macro/args_macro.dart';

@Args()
class MyArgs {
  bool? nullableBool = null;
  final bool? finalNullableBool = null;
}

void main() {}
