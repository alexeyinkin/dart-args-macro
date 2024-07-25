import 'dart:convert';

import '../argument.dart';
import '../introspection_data.dart';
import 'visitor.dart';

/// Generates the code that parses option values into the data class instance.
class ParseGenerator extends ArgumentVisitor<List<Object>> {
  ParseGenerator(this.intr);

  final IntrospectionData intr;

  List<Object> generate() {
    final name = intr.clazz.identifier.name;
    final ids = intr.ids;

    return [
      //
      '$name parse(', ids.List, '<', ids.String, '> argv) {\n',
      '  final wrapped = parser.parse(argv);\n',
      '  return $name(\n',
      for (final argument in intr.arguments.values) ...[
        ...argument.accept(this),
        ',\n',
      ],
      '  );\n',
      '}\n',
    ];
  }

  @override
  List<Object> visitInt(IntArgument argument) {
    return [
      argument.intr.name,
      ': ',
      intr.ids.int,
      '.parse(wrapped.option(${jsonEncode(argument.optionName)})!)',
    ];
  }

  @override
  List<Object> visitString(StringArgument argument) {
    return [
      argument.intr.name,
      ': wrapped.option(${jsonEncode(argument.optionName)})!',
    ];
  }
}
