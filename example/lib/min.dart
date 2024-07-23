import 'package:args_macro/args_macro.dart';

@Args()
class HelloArgs {
  final String name;
  final int count;
}

void main(List<String> argv) {
  final parser = HelloArgsParser(); // Generated class.
  final HelloArgs args = parser.parse(argv);

  for (int n = 0; n < args.count; n++) {
    print('Hello, ${args.name}!');
  }
}
