import 'package:args_macro/args_macro.dart';

@Args()
class MyArgs {
  final bool b = false;
  final double d = 1.0;
  final MyEnum e = MyEnum.a;
  final int n = 1;
  final List<String> listStr = ['aaa'];
  final Set<String> setStr = {'bbb'};
  final String str = 'abc';
}

enum MyEnum {
  a,
}

void main() {}
