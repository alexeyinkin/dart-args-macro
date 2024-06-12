import 'package:args_macro/args_macro.dart';

@Args()
class MyArgs {
  //             A field with an initializer cannot be final ↓
  //               Boolean must have a default value. ↓
  //               Boolean cannot be nullable. ↓
  final bool requiredBool; //                         *

  final bool? finalNullableBool; //            *      *

  bool? nullableBoolInit = null; //            *
  final bool? finalNullableBoolInit = null; // *             *
}

void main() {}
