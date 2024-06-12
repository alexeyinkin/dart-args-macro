import 'package:args_macro/args_macro.dart';

typedef GenericListAlias = List;
typedef ListAlias<T> = List<T>;
typedef StringAlias = String;

@Args()
class MyArgs {
  //                                      A List requires a type parameter ↓
  //                                             Cannot resolve type. ↓
  //                                  Expected 0 type arguments. ↓
  //                             The only allowed types are ↓
  final List genericList; //                                               *
  final GenericListAlias genericListAlias; //                              *
  final GenericListAlias<String> genericListAliasString; // *    *    *
  final List<Map> listMap; //                               *
  final List<MyClass> listMyClass; //                       *

  // OK.
  final List<String> listString;
  final ListAlias<StringAlias> listAliasStringAlias;
}

class MyClass {}

void main() {}
