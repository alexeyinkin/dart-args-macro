import 'dart:convert';

import 'package:macro_util/macro_util.dart';
import 'package:macros/macros.dart';

import '../argument.dart';
import '../introspection_data.dart';
import 'visitor.dart';

class ParseGenerator extends ArgumentVisitor<List<Object>> {
  ParseGenerator(this.clazz, this.intr);

  final ClassDeclaration clazz;
  final IntrospectionData intr;

  List<Object> generate() {
    final name = clazz.identifier.name;
    final c = intr.codes;

    return [
      //
      name, ' parse(', c.List, '<', c.String, '> argv) {\n',
      '  try {\n',
      '    final wrapped = _parseWrapped(argv);\n',
      '    return $name(\n',
      for (final argument in intr.arguments.arguments.values)
        ...[...argument.accept(this), ',\n'].indent(6),
      '    );\n',
      '  } on ', c.ArgumentError, ' catch (e) {\n',
      '    ', c.stderr, '.writeln(e.message);', '\n',
      '    ', c.stderr, '.writeln();', '\n',
      '    _printUsage(', c.stderr, ');\n',
      '    ', c.exit, '(64);\n',
      '  } on ', c.FormatException, ' catch (e) {\n',
      '    ', c.stderr, '.writeln(e.message);', '\n',
      '    ', c.stderr, '.writeln();', '\n',
      '    _printUsage(', c.stderr, ');\n',
      '    ', c.exit, '(64);\n',
      '  }\n',
      '}\n',
    ];
  }

  // bool:
  //     return [
  //     fieldIntr.name,
  //     ': wrapped.flag(${jsonEncode(optionName)})',
  //     ',\n',
  //     ];

  @override
  List<Object> visitDouble(DoubleArgument argument) =>
      _visitIntDouble(argument, intr.codes.double);

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
      _visitIntDouble(argument, intr.codes.int);

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
    NamedTypeAnnotationCode typeCode,
  ) {
    final valueGetter = _getOptionValueGetter(argument);

    return [
      argument.intr.name,
      ': ',
      if (argument.intr.fieldDeclaration.type.isNullable)
        '$valueGetter == null ? null : ',
      typeCode,
      '.tryParse($valueGetter!)',
      ' ?? (throw ',
      intr.codes.ArgumentError,
      '.value(\n',
      '  $valueGetter,\n',
      '  "${argument.optionName}",\n',
      '  "Cannot parse the value of \\"${argument.optionName}\\" into ${typeCode.name.name}, \\"" + $valueGetter! + "\\" given.",\n',
      ')',
      ')',
    ];
  }

  String _getOptionValueGetter(Argument argument) {
    return 'wrapped.option(${jsonEncode(argument.optionName)})';
  }
}
