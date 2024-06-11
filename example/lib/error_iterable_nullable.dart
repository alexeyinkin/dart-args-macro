import 'package:args_macro/args_macro.dart';

@Args()
class MyArgs {
  //       A List cannot be nullable because it is just empty ↓
  // A Set cannot be nullable because it is just empty ↓
  final List<String>? nullableStringList; //                  1
  final Set<String>? nullableStringSet; //             1
}

void main() {}
