import 'package:args_macro/args_macro.dart';

typedef GenericListAlias = List;
typedef ListAlias<T> = List<T>;
typedef StringAlias = String;

@Args()
class MyArgs {
  final Map map;
  final List genericList;
  final GenericListAlias genericListAlias;
  final GenericListAlias<String> genericListAliasString;
  final List<Map> listMap;
  final Set genericSet;
  final Set<Map> setMap;

  // OK.
  final List<String> listString;
  final ListAlias<StringAlias> listAliasStringAlias;
}

void main() {}
