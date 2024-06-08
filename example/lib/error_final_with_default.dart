import 'package:args_macro/args_macro.dart';

@Args()
class MyArgs {
  final String str = 'abc';
  final int n = 1;
  final double d = 1.0;
  final bool b = false;
  final MyEnum e = MyEnum.a;
}

enum MyEnum {
  a,
}

void main(List<String> argv) {}
