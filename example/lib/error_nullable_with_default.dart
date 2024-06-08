import 'package:args_macro/args_macro.dart';

@Args()
class MyArgs {
  String? str = 'abc';
  int? n = 1;
  double? d = 1.0;
  bool? b = false;
  MyEnum? e = MyEnum.a;
}

enum MyEnum {
  a,
}

void main(List<String> argv) {}
