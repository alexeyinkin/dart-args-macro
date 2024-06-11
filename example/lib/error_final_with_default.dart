import 'package:args_macro/args_macro.dart';

@Args()
class MyArgs {
  // A field with an initializer cannot be final ↓
  final bool b = false; //                       1
  final double d = 1.0; //                       2
  final MyEnum e = MyEnum.a; //                  3
  final int n = 1; //                            4
  final List<String> listStr = ['aaa']; //       5
  final Set<String> setStr = {'bbb'}; //         6
  final String str = 'abc'; //                   7
}

enum MyEnum {
  a,
}

void main() {}
