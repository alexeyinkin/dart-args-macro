import 'package:args_macro/args_macro.dart';

@Args(
  description: 'The command description.',
  executableName: 'executable_name',
)
class MyArgs {
  final String requiredString;
  final int requiredInt;
  final double requiredDouble;
  final Fruit requiredEnum;
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
