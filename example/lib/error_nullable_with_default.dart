import 'package:args_macro/args_macro.dart';

@Args()
class MyArgs {
  bool? b = false;
  double? d = 1.0;
  MyEnum? e = MyEnum.a;
  int? n = 1;
  List<String>? listStr = ['aaa'];
  Set<String>? setStr = {'bbb'};
  String? str = 'abc';
}

enum MyEnum {
  a,
}

void main() {}
