import 'package:args_macro/args_macro.dart';

@Args()
class MyArgs {
  // A field with an initializer must be non-nullable ↓
  //               Boolean cannot be nullable. ↓
  bool? b = false; //                          *
  double? d = 1.0; //                                 *
  MyEnum? e = MyEnum.a; //                            *
  int? n = 1; //                                      *
  String? str = 'abc'; //                             *
}

enum MyEnum {
  a,
}

void main() {}
