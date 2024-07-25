import 'dart:convert';

import 'package:macro_util/macro_util.dart';

import '../argument.dart';
import '../introspection_data.dart';
import 'mock_data_object_generator.dart';
import 'visitor.dart';

/// Generates '_addOptions' function of the parser
/// which adds all options to it.
class AddOptionsGenerator extends ArgumentVisitor<List<Object>> {
  // ignore: public_member_api_docs
  AddOptionsGenerator(this.intr);

  @override
  final IntrospectionData intr;

  // ignore: public_member_api_docs
  List<Object> generate() {
    final arguments = intr.arguments.values.where((a) => a.isValid);

    return [
      //
      'void _addOptions() {\n',
      for (final argument in arguments)
        ...[...argument.accept(this), '\n'].indent(),
      '}\n',
    ];
  }

  @override
  List<Object> visitBool(BoolArgument argument) {
    return [
      //
      'parser.addFlag(\n',
      '  ${argument.flagNameGetter},\n',
      '  negatable: false,\n',
      ..._getHelpMessageIfAny(argument).indent(),
      ');\n',
    ];
  }

  @override
  List<Object> visitDouble(DoubleArgument argument) =>
      _visitStringIntDouble(argument);

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
      ..._getHelpMessageIfAny(argument).indent(),
      ');\n',
    ];
  }

  @override
  List<Object> visitInt(IntArgument argument) =>
      _visitStringIntDouble(argument);

  @override
  List<Object> visitInvalidType(InvalidTypeArgument argument) {
    return const [];
  }

  @override
  List<Object> visitIterableDouble(IterableDoubleArgument argument) =>
      _visitIterableStringIntDouble(argument);

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
      ..._getHelpMessageIfAny(argument).indent(),
      ');\n',
    ];
  }

  @override
  List<Object> visitIterableInt(IterableIntArgument argument) =>
      _visitIterableStringIntDouble(argument);

  @override
  List<Object> visitIterableString(IterableStringArgument argument) =>
      _visitIterableStringIntDouble(argument);

  @override
  List<Object> visitString(StringArgument argument) =>
      _visitStringIntDouble(argument);

  List<Object> _visitStringIntDouble(Argument argument) {
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
      ..._getHelpMessageIfAny(argument).indent(),
      ');\n',
    ];
  }

  List<Object> _visitIterableStringIntDouble(IterableArgument argument) {
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
      ..._getHelpMessageIfAny(argument).indent(),
      ');\n',
    ];
  }

  List<Object> _getHelpMessageIfAny(Argument argument) {
    final helpFieldName = '_${argument.intr.name}Help';
    final helpField = intr.fields[helpFieldName];

    if (helpField == null || !helpField.fieldDeclaration.hasStatic) {
      return const [];
    }

    return [
      'help: ',
      intr.clazz.identifier.name,
      '.',
      helpFieldName,
    ];
  }
}
