import 'package:args_macro/args_macro.dart';

typedef GenericSetAlias = Set;
typedef SetAlias<T> = Set<T>;
typedef StringAlias = String;

@Args()
class MyArgs {
  //                               A List type parameter must be non-nullable ↓
  //                                     A Set requires a type parameter ↓
  //                                           Cannot resolve type. ↓
  //                                Expected 0 type arguments. ↓
  //                           The only allowed types are ↓
  final Set genericSet; //                                               *
  final GenericSetAlias genericSetAlias; //                              *
  final GenericSetAlias<String> genericSetAliasString; // *    *    *
  final Set<Map> setMap; //                               *
  final Set<MyClass> setMyClass; //                       *
  final Set<int?> setNullableInt; //                                          *
  final Set<MyEnum?> setNullableEnum; //                                      *

  // OK.
  final Set<String> setString;
  final SetAlias<StringAlias> setAliasStringAlias;
}

class MyClass {}

enum MyEnum { a }

void main() {}
