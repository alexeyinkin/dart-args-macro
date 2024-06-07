import 'dart:convert';

import 'package:macro_util/macro_util.dart';

import '../argument.dart';
import '../introspection_data.dart';
import 'mock_data_object_generator.dart';
import 'visitor.dart';

class AddOptionsGenerator extends ArgumentVisitor<List<Object>> {
  AddOptionsGenerator(this.intr);

  final IntrospectionData intr;

  List<Object> generate() {
    return [
      //
      'void _addOptions() {\n',
      for (final argument in intr.arguments.arguments.values)
        ...[...argument.accept(this), '\n'].indent(),
      '}\n',
    ];
  }

  // bool:
  // List<Object> _getParserInitializationForBool(
  //     MemberDeclarationBuilder builder, {
  //       required FieldDeclaration field,
  //       required String optionName,
  //     }) {
  //   if (field.type.isNullable) {
  //     builder.report(
  //       Diagnostic(
  //         DiagnosticMessage(
  //           'Boolean cannot be nullable.',
  //           target: field.asDiagnosticTarget,
  //         ),
  //         Severity.error,
  //       ),
  //     );
  //
  //     return const [];
  //   }
  //
  //   builder.report(
  //     Diagnostic(
  //       DiagnosticMessage(
  //         'Boolean must have a default value.',
  //         target: field.asDiagnosticTarget,
  //       ),
  //       Severity.error,
  //     ),
  //   );
  //
  //   return const [];
  // }

  @override
  List<Object> visitDouble(DoubleArgument arg) => _visitStringIntDouble(arg);

  @override
  List<Object> visitEnum(EnumArgument argument) {
    final field = argument.intr.fieldDeclaration;
    final values =
        argument.enumIntr.values.map((v) => v.name).toList(growable: false);

    return [
      //
      'parser.addOption(\n',
      '  "${argument.optionName}",\n',
      '  allowed: ${jsonEncode(values)},\n',
      if (field.hasInitializer) ...[
        '  defaultsTo: ',
        MockDataObjectGenerator.fieldName,
        '.',
        argument.intr.name,
        '?.name',
        ',\n',
      ] else if (!field.type.isNullable)
        '  mandatory: true,\n',
      ');\n',
    ];
  }

  @override
  List<Object> visitInt(IntArgument arg) => _visitStringIntDouble(arg);

  @override
  List<Object> visitString(StringArgument arg) => _visitStringIntDouble(arg);

  List<Object> _visitStringIntDouble(Argument argument) {
    final field = argument.intr.fieldDeclaration;

    return [
      //
      'parser.addOption(\n',
      '  "${argument.optionName}",\n',
      if (field.hasInitializer) ...[
        '  defaultsTo: ',
        MockDataObjectGenerator.fieldName,
        '.',
        argument.intr.name,
        '?.toString()',
        ',\n',
      ] else if (!field.type.isNullable)
        '  mandatory: true,\n',
      ');\n',
    ];
  }
}
