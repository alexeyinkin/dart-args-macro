import 'dart:convert';

import 'package:macro_util/macro_util.dart';
import 'package:macros/macros.dart';

import '../argument.dart';
import '../introspection_data.dart';
import 'mock_data_object_generator.dart';
import 'positional_param_generator.dart';
import 'visitor.dart';

/// Generates the code that parses option values into the data class instance.
class ParseGenerator extends ArgumentVisitor<List<Object>>
    with PositionalParamGenerator {
  // ignore: public_member_api_docs
  ParseGenerator(this.intr);

  @override
  final IntrospectionData intr;

  // ignore: public_member_api_docs
  List<Object> generate() {
    final name = intr.clazz.identifier.name;
    final ids = intr.ids;

    final arguments = intr.arguments.values.where(
      (a) =>
          a.intr.constructorHandling ==
          FieldConstructorHandling.namedOrPositional,
    );

    return [
      //
      name, ' parse(', ids.List, '<', ids.String, '> argv) {\n',
      '  try {\n',
      '    final wrapped = _parseWrapped(argv);\n',
      '    return $name(\n',
      for (final param in getPositionalParams()) ...[...param, ',\n'].indent(6),
      for (final argument in arguments)
        ...[...argument.accept(this), ',\n'].indent(6),
      '    );\n',
      '  } on ', ids.ArgumentError, ' catch (e) {\n',
      '    ', ids.stderr, '.writeln(e.message);', '\n',
      '    ', ids.stderr, '.writeln();', '\n',
      '    _printUsage(', ids.stderr, ');\n',
      '    ', ids.exit, '(64);\n',
      '  } on ', ids.FormatException, ' catch (e) {\n',
      '    ', ids.stderr, '.writeln(e.message);', '\n',
      '    ', ids.stderr, '.writeln();', '\n',
      '    _printUsage(', ids.stderr, ');\n',
      '    ', ids.exit, '(64);\n',
      '  }\n',
      '}\n',
    ];
  }

  @override
  List<Object> visitBool(BoolArgument argument) {
    final def = '${MockDataObjectGenerator.fieldName}.${argument.intr.name}';

    return [
      argument.intr.name,
      ': ',
      'wrapped.wasParsed(${argument.flagNameGetter})',
      ' ? !$def',
      ' : $def',
    ];
  }

  @override
  List<Object> visitDouble(DoubleArgument argument) =>
      _visitIntDouble(argument, intr.ids.double);

  @override
  List<Object> visitEnum(EnumArgument argument) {
    final valueGetter = _getOptionValueGetter(argument);

    return [
      argument.intr.name,
      ': ',
      if (argument.intr.fieldDeclaration.type.isNullable)
        '$valueGetter == null ? null : ',
      argument.intr.unaliasedTypeDeclaration.identifier,
      '.values.byName($valueGetter!)',
    ];
  }

  @override
  List<Object> visitInt(IntArgument argument) =>
      _visitIntDouble(argument, intr.ids.int);

  @override
  List<Object> visitInvalidType(InvalidTypeArgument argument) {
    return [
      argument.intr.name,
      ': _silenceUninitializedError',
    ];
  }

  @override
  List<Object> visitIterableDouble(IterableDoubleArgument argument) =>
      _visitIterableIntDouble(
        argument,
        intr.ids.double,
      );

  @override
  List<Object> visitIterableEnum(IterableEnumArgument argument) {
    final valueGetter = _getMultiOptionValueGetter(argument);

    final result = [
      //
      argument.intr.name,
      ': $valueGetter.map((e) => ',
      argument.enumIntr.unaliasedTypeDeclaration.identifier,
      '.values.byName(e)',
      ')',
    ];

    switch (argument.iterableType) {
      case IterableType.list:
        return [
          ...result,
          '.toList(growable: false)',
        ];
      case IterableType.set:
        return [
          ...result,
          '.toSet()',
        ];
    }
  }

  @override
  List<Object> visitIterableInt(IterableIntArgument argument) =>
      _visitIterableIntDouble(
        argument,
        intr.ids.int,
      );

  @override
  List<Object> visitIterableString(IterableStringArgument argument) {
    final valueGetter = _getMultiOptionValueGetter(argument);

    switch (argument.iterableType) {
      case IterableType.list:
        return [
          argument.intr.name,
          ': $valueGetter',
        ];
      case IterableType.set:
        return [
          argument.intr.name,
          ': $valueGetter.toSet()',
        ];
    }
  }

  @override
  List<Object> visitString(StringArgument argument) {
    final valueGetter = _getOptionValueGetter(argument);

    return [
      argument.intr.name,
      ': $valueGetter',
      if (!argument.intr.fieldDeclaration.type.isNullable) '!',
    ];
  }

  List<Object> _visitIntDouble(
    Argument argument,
    Identifier typeId,
  ) {
    final valueGetter = _getOptionValueGetter(argument);

    return [
      argument.intr.name,
      ': ',
      if (argument.intr.fieldDeclaration.type.isNullable)
        '$valueGetter == null ? null : ',
      typeId,
      '.tryParse($valueGetter!)',
      ' ?? (throw ',
      intr.ids.ArgumentError,
      '.value(\n',
      '  $valueGetter,\n',
      '  "${argument.optionName}",\n',
      '  "Cannot parse the value of \\"${argument.optionName}\\" into ${typeId.name}, \\"" + $valueGetter! + "\\" given.",\n',
      ')',
      ')',
    ];
  }

  List<Object> _visitIterableIntDouble(
    IterableArgument argument,
    Identifier typeId,
  ) {
    final valueGetter = _getMultiOptionValueGetter(argument);

    final result = [
      //
      argument.intr.name,
      ': $valueGetter.map((e) => ', typeId, '.tryParse(e) ?? (throw ',
      intr.ids.ArgumentError,
      '.value(\n',
      '  $valueGetter,\n',
      '  "${argument.optionName}",\n',
      '  "Cannot parse the value of \\"${argument.optionName}\\" into ${typeId.name}, \\"" + e + "\\" given.",\n',
      ')', // value
      ')', // throw
      ')', // map
    ];

    switch (argument.iterableType) {
      case IterableType.list:
        return [
          ...result,
          '.toList(growable: false)',
        ];
      case IterableType.set:
        return [
          ...result,
          '.toSet()',
        ];
    }
  }

  String _getOptionValueGetter(Argument argument) {
    return 'wrapped.option(${jsonEncode(argument.optionName)})';
  }

  String _getMultiOptionValueGetter(Argument argument) {
    return 'wrapped.multiOption(${jsonEncode(argument.optionName)})';
  }
}
