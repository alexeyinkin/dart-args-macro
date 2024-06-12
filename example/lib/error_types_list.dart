import 'package:args_macro/args_macro.dart';

typedef GenericListAlias = List;
typedef ListAlias<T> = List<T>;
typedef StringAlias = String;

@Args()
class MyArgs {
  //                             A List type parameter must be non-nullable ↓
  //                                   A List requires a type parameter ↓
  //                                           Cannot resolve type. ↓
  //                                 Expected 0 type arguments. ↓
  //                             The only allowed types are ↓
  final List genericList; //                                            *
  final GenericListAlias genericListAlias; //                           *
  final GenericListAlias<String> genericListAliasString; // *   *   *
  final List<Map> listMap; //                               *
  final List<MyClass> listMyClass; //                       *
  final List<int?> listNullableInt; //                                      *
  final List<MyEnum?> listNullableEnum; //                                  *

  // OK.
  final List<String> listString;
  final ListAlias<StringAlias> listAliasStringAlias;
}

class MyClass {}

enum MyEnum { a }

void main() {}
