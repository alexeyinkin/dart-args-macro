import 'package:args_macro/args_macro.dart';

@Args(
  description: 'The command description.',
  executableName: 'executable_name',
)
class MyArgs {
  final String requiredString;
  final String? optionalString;

  final int requiredInt;
  final int? optionalInt;

  final double requiredDouble;
  final double? optionalDouble;

  final Fruit requiredEnum;
  final Fruit? optionalEnum;
}

enum Fruit {
  apple,
  banana,
  orange,
}

void main(List<String> argv) {
  final parser = MyArgsParser(); // Generated class.
  final MyArgs args = parser.parse(argv);

  stdout.write(args.toDebugString());
}
