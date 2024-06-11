import 'package:args_macro/args_macro.dart';

typedef GenericListAlias = List;
typedef ListAlias<T> = List<T>;
typedef StringAlias = String;

@Args()
class MyArgs {
  //                                        A Set requires a type parameter ↓
  //                                   A List requires a type parameter ↓
  //                                           Cannot resolve type. ↓
  //                                 Expected 0 type arguments. ↓
  //                             The only allowed types are ↓
  final Map map; //                                         1
  final List genericList; //                                            1
  final GenericListAlias genericListAlias; //                           2
  final GenericListAlias<String> genericListAliasString; // 2   1   1
  final List<Map> listMap; //                               3
  final Set genericSet; //                                                  1
  final Set<Map> setMap; //                                 4

  // OK.
  final List<String> listString;
  final ListAlias<StringAlias> listAliasStringAlias;
}

void main() {}
