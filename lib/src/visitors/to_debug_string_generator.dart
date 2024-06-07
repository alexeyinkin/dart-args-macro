import 'dart:convert';

import 'package:macro_util/macro_util.dart';

import '../introspection_data.dart';

class ToDebugStringGenerator {
  ToDebugStringGenerator(this.intr);

  final IntrospectionData intr;

  List<Object> generate() {
    final c = intr.codes;

    return [
      //
      c.String, ' toDebugString() {\n',
      '  final buffer = ', c.StringBuffer, '();\n\n',
      for (final argument in intr.arguments.arguments.values)
        ...[..._fieldToDebugString(argument.intr), '\n'].indent(),
      '  return buffer.toString();\n',
      '}\n',
    ];
  }

  List<Object> _fieldToDebugString(FieldIntrospectionData fieldIntr) {
    final className = fieldIntr.unaliasedTypeDeclaration.identifier.name;
    return [
      //
      'buffer.write(${jsonEncode(fieldIntr.name)});\n',
      'buffer.write(": ");\n',
      'buffer.write(', fieldIntr.name, ');\n',
      'buffer.write(" (', className, ')");\n',
      'buffer.writeln();\n',
    ];
  }
}
