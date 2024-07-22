import 'dart:convert';

import 'package:macro_util/macro_util.dart';

import '../argument.dart';
import '../introspection_data.dart';

/// Generates 'toDebugString()' function on the data class
/// to dump data for use in the tests of this package.
///
/// Do not use this function. It will be replaced with JsonCodable
/// when it supports enums.
class ToDebugStringGenerator {
  // ignore: public_member_api_docs
  ToDebugStringGenerator(this.intr);

  // ignore: public_member_api_docs
  final IntrospectionData intr;

  // ignore: public_member_api_docs
  List<Object> generate() {
    final ids = intr.ids;

    return [
      //
      ids.String, ' toDebugString() {\n',
      '  final buffer = ', ids.StringBuffer, '();\n\n',
      for (final argument in intr.arguments.arguments.values)
        if (argument.isValid)
          ...[..._fieldToDebugString(argument), '\n'].indent(),
      '  return buffer.toString();\n',
      '}\n',
    ];
  }

  List<Object> _fieldToDebugString(Argument argument) {
    final fieldIntr = argument.intr;

    if (fieldIntr is! ResolvedFieldIntrospectionData) {
      return const [];
    }

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
