import 'package:args_macro/args_macro.dart';

@Args()
class MyArgs {
  //       A List cannot be nullable because it is just empty ↓
  // A Set cannot be nullable because it is just empty ↓
  List<double>? listDouble = [1.0]; //                        *
  List<int>? listInt = [1]; //                                *
  List<String>? listStr = ['aaa']; //                         *
  Set<double>? setDouble = {1.0}; //                   *
  Set<int>? setInt = {1}; //                           *
  Set<String>? setStr = {'bbb'}; //                    *
}

enum MyEnum { a }

void main() {}
