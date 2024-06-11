import 'package:args_macro/args_macro.dart';

@Args()
class MyArgs {
  //             A List cannot be nullable because it is just empty ↓
  //       A Set cannot be nullable because it is just empty ↓
  // A field with an initializer must be non-nullable ↓
  //               Boolean cannot be nullable. ↓
  bool? b = false; //                          1
  double? d = 1.0; //                                 1
  MyEnum? e = MyEnum.a; //                            2
  int? n = 1; //                                      3
  List<String>? listStr = ['aaa']; //                               1
  Set<String>? setStr = {'bbb'}; //                          1
  String? str = 'abc'; //                             4
}

enum MyEnum {
  a,
}

void main() {}
