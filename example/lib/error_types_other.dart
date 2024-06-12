import 'package:args_macro/args_macro.dart';

typedef StringAlias = String;

@Args()
class MyArgs {
  // An explicitly declared type is required here. ↓
  //    The only allowed types are ↓
  final omitted; //                                *
  final inferred = 1; //                           *
  final Map map; //                *
  final MyClass myClass; //        *
  final num myNum; //              *
  final Iterable<int> iterable; // *

  // OK.
  final StringAlias str;
}

class MyClass {}

void main() {}
