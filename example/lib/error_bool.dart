import 'package:args_macro/args_macro.dart';

@Args()
class MyArgs {
  //             A field with an initializer cannot be final ↓
  //               Boolean must have a default value. ↓
  //               Boolean cannot be nullable. ↓
  final bool requiredBool; //                         1

  final bool? finalNullableBool; //            1      2

  bool? nullableBoolInit = null; //            2
  final bool? finalNullableBoolInit = null; // 3             1
}

void main() {}
