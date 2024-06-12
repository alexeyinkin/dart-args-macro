import 'package:args_macro/args_macro.dart';

typedef StringAlias = String;

@Args()
class MyArgs {
  // An argument field name cannot contain an underscore. ↓
  int _underscore; //                                     *
  int mid_underscore = 1; //                              *
}

void main() {}
