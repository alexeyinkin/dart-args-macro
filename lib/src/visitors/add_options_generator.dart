import 'dart:convert';

import '../argument.dart';
import '../introspection_data.dart';
import 'mock_data_object_generator.dart';
import 'visitor.dart';

/// Generates '_addOptions' function of the parser
/// which adds all options to it.
class AddOptionsGenerator extends ArgumentVisitor<List<Object>> {
  AddOptionsGenerator(this.intr);

  @override
  final IntrospectionData intr;

  List<Object> generate() {
    return [
      //
      'void _addOptions() {\n',
      for (final argument in intr.arguments.values) ...[
        ...argument.accept(this),
        '\n',
      ],
      '}\n',
    ];
  }

  @override
  List<Object> visitEnum(EnumArgument argument) {
    final field = argument.intr.fieldDeclaration;
    final values =
        argument.enumIntr.values.map((v) => v.name).toList(growable: false);

    return [
      //
      'parser.addOption(\n',
      '  ${jsonEncode(argument.optionName)},\n',
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
  List<Object> visitInt(IntArgument argument) => _visitStringInt(argument);

  @override
  List<Object> visitInvalidType(InvalidTypeArgument argument) {
    return const [];
  }

  @override
  List<Object> visitIterableEnum(IterableEnumArgument argument) {
    final field = argument.intr.fieldDeclaration;
    final values =
        argument.enumIntr.values.map((v) => v.name).toList(growable: false);

    return [
      //
      'parser.addMultiOption(\n',
      '  ${jsonEncode(argument.optionName)},\n',
      '  allowed: ${jsonEncode(values)},\n',
      if (field.hasInitializer) ...[
        '  defaultsTo: ',
        MockDataObjectGenerator.fieldName,
        '.',
        argument.intr.name,
        '.map((e) => e.name)',
        ',\n',
      ],
      ');\n',
    ];
  }

  @override
  List<Object> visitIterableInt(IterableIntArgument argument) =>
      _visitIterableStringInt(argument);

  @override
  List<Object> visitIterableString(IterableStringArgument argument) =>
      _visitIterableStringInt(argument);

  @override
  List<Object> visitString(StringArgument argument) =>
      _visitStringInt(argument);

  List<Object> _visitStringInt(Argument argument) {
    final field = argument.intr.fieldDeclaration;

    return [
      //
      'parser.addOption(\n',
      '  ${jsonEncode(argument.optionName)},\n',
      if (field.hasInitializer) ...[
        '  defaultsTo: ',
        MockDataObjectGenerator.fieldName,
        '.',
        argument.intr.name,
        '.toString()',
        ',\n',
      ] else if (!field.type.isNullable)
        '  mandatory: true,\n',
      ');\n',
    ];
  }

  List<Object> _visitIterableStringInt(IterableArgument argument) {
    final field = argument.intr.fieldDeclaration;

    return [
      //
      'parser.addMultiOption(\n',
      '  ${jsonEncode(argument.optionName)},\n',
      if (field.hasInitializer) ...[
        '  defaultsTo: ',
        MockDataObjectGenerator.fieldName,
        '.',
        argument.intr.name,
        '.map((e) => e.toString())',
        ',\n',
      ],
      ');\n',
    ];
  }
}
