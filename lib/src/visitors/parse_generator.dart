import 'dart:convert';

import 'package:macro_util/macro_util.dart';

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

    final arguments = intr.arguments.values.where(
      (a) =>
          a.intr.constructorHandling ==
          FieldConstructorHandling.namedOrPositional,
    );

    return [
      //
      name, ' parse(', ids.List, '<', ids.String, '> argv) {\n',
      '  final wrapped = parser.parse(argv);\n',
      '  return $name(\n',
      for (final param in _getPositionalParams()) ...[...param, ',\n'],
      for (final argument in arguments) ...[
        ...argument.accept(this),
        ',\n',
      ],
      '  );\n',
      '}\n',
    ];
  }

  List<List<Object>> _getPositionalParams() {
    final result = <List<Object>>[];
    final fields = intr.fields.values.where(
      (f) => f.constructorHandling == FieldConstructorHandling.positional,
    );

    for (final _ in fields) {
      result.add([
        '_silenceUninitializedError',
      ]);
    }

    return result;
  }

  @override
  List<Object> visitEnum(EnumArgument argument) {
    final valueGetter = _getOptionValueGetter(argument);

    return [
      argument.intr.name,
      ': ',
      argument.intr.deAliasedTypeDeclaration.identifier,
      '.values.byName($valueGetter!)',
    ];
  }

  @override
  List<Object> visitInt(IntArgument argument) {
    final valueGetter = _getOptionValueGetter(argument);

    return [
      argument.intr.name,
      ': ',
      intr.ids.int,
      '.parse($valueGetter!)',
    ];
  }

  @override
  List<Object> visitInvalidType(InvalidTypeArgument argument) {
    return [
      argument.intr.name,
      ': _silenceUninitializedError',
    ];
  }

  @override
  List<Object> visitIterableEnum(IterableEnumArgument argument) {
    final valueGetter = _getMultiOptionValueGetter(argument);

    final result = [
      //
      argument.intr.name,
      ': $valueGetter.map((e) => ',
      argument.enumIntr.deAliasedTypeDeclaration.identifier,
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
  List<Object> visitIterableInt(IterableIntArgument argument) {
    final valueGetter = _getMultiOptionValueGetter(argument);

    final result = [
      //
      argument.intr.name,
      ': $valueGetter.map((e) => ', intr.ids.int, '.parse(e))',
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
      ': $valueGetter!',
    ];
  }

  String _getOptionValueGetter(Argument argument) {
    return 'wrapped.option(${jsonEncode(argument.optionName)})';
  }

  String _getMultiOptionValueGetter(Argument argument) {
    return 'wrapped.multiOption(${jsonEncode(argument.optionName)})';
  }
}
