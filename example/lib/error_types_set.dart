import 'package:args_macro/args_macro.dart';

typedef GenericSetAlias = Set;
typedef SetAlias<T> = Set<T>;
typedef StringAlias = String;

@Args()
class MyArgs {
  //                                        A Set requires a type parameter ↓
  //                                             Cannot resolve type. ↓
  //                                 Expected 0 type arguments. ↓
  //                           The only allowed types are ↓
  final Set genericSet; //                                                  *
  final GenericSetAlias genericSetAlias; //                                 *
  final GenericSetAlias<String> genericSetAliasString; // *     *     *
  final Set<Map> setMap; //                               *
  final Set<MyClass> setMyClass; //                       *

  // OK.
  final Set<String> setString;
  final SetAlias<StringAlias> setAliasStringAlias;
}

class MyClass {}

void main() {}
