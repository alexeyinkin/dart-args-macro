import 'package:args_macro/args_macro.dart';

@Args()
class MyArgs {
  // A field with an initializer cannot be final ↓
  final List<double> listDouble = [1.0]; //      *
  final List<int> listInt = [1]; //              *
  final List<String> listStr = ['aaa']; //       *
  final Set<double> setDouble = {1.0}; //        *
  final Set<int> setInt = {1}; //                *
  final Set<String> setStr = {'bbb'}; //         *
}

enum MyEnum {
  a,
}

void main() {}
