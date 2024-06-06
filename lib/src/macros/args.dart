import 'dart:async';
import 'dart:convert';

import 'package:common_macros/common_macros.dart';
import 'package:macro_util/macro_util.dart';
import 'package:macros/macros.dart';

import '../util/codes.dart';
import '../util/enum.dart';
import '../util/libraries.dart';
import '../util/resolved_identifiers.dart';
import '../util/static_types.dart';

const _helpFlag = 'help';
const _hFlag = 'h';

/// Creates a command line argument parser from your data class.
macro class Args implements ClassTypesMacro, ClassDeclarationsMacro {
  // ignore: public_member_api_docs
  const Args({
    this.description,
    this.executableName,
  });

  /// Shows before the options help.
  final String? description;

  /// Shows in the usage line.
  final String? executableName;

  @override
  Future<void> buildTypesForClass(
    ClassDeclaration clazz,
    ClassTypeBuilder builder,
  ) async {
    final name = clazz.identifier.name;
    final parserName = '${name}Parser';

    builder.declareType(
      name,
      DeclarationCode.fromString('class $parserName {}\n'),
    );
  }

  @override
  Future<void> buildDeclarationsForClass(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {
    builder.log('buildDeclarationsForClass');
    final intr = await _IntrospectionData.fill(clazz, builder);

    await _declareConstructor(clazz, builder);
    _declareToDebugString(builder, intr);
    await _augmentParser(clazz, builder, intr);
  }

  Future<void> _declareConstructor(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {
    await const UnnamedConstructor().buildDeclarationsForClass(clazz, builder);
  }

  void _declareToDebugString(
    MemberDeclarationBuilder builder,
    _IntrospectionData intr,
  ) {
    final c = intr.codes;

    builder.declareInType(
      DeclarationCode.fromParts(
        [
          //
          c.String, ' toDebugString() {\n',
          '  final buffer = ', c.StringBuffer, '();\n\n',
          for (final fieldIntr in intr.fields.values)
            ...[..._fieldToDebugString(fieldIntr), '\n'].indent(),
          '  return buffer.toString();\n',
          '}\n',
        ].indent(),
      ),
    );
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

  Future<void> _augmentParser(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
    _IntrospectionData intr,
  ) async {
    final parserName = _getParserName(clazz);

    builder.declareInLibrary(
      DeclarationCode.fromParts([
        //
        'augment class $parserName {\n',
        '  final parser = ', intr.codes.ArgParser, '();\n',
        ..._getConstructor(clazz).indent(),
        ...(await _getInitializeParser(clazz, builder, intr)).indent(),
        ...(await _getParse(clazz, builder, intr)).indent(),
        ..._getParseWrapped(intr).indent(),
        ..._getPrintUsage(intr).indent(),
        '}\n',
      ]),
    );
  }

  String _getParserName(ClassDeclaration clazz) {
    final name = clazz.identifier.name;
    return '${name}Parser';
  }

  List<Object> _getConstructor(ClassDeclaration clazz) {
    final parserName = _getParserName(clazz);

    return [
      //
      parserName, '() {\n',
      '  _initializeParser();\n',
      '}\n',
    ];
  }

  Future<List<Object>> _getInitializeParser(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
    _IntrospectionData intr,
  ) async {
    return [
      //
      'void _initializeParser() {\n',
      ...(await _getParserInitialization(clazz, builder, intr)).indent(),
      '}\n',
    ];
  }

  Future<List<Object>> _getParserInitialization(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
    _IntrospectionData intr,
  ) async {
    final initializers = [
      ...await Future.wait([
        for (final fieldIntr in intr.fields.values)
          _getParserInitializationForField(
            clazz,
            builder,
            intr,
            fieldIntr,
          ),
      ]),
      _getParserInitializationForHelp(),
    ];

    return initializers
        .alternateWith(['\n'])
        .expand((e) => e)
        .toList(growable: false);
  }

  Future<List<Object>> _getParserInitializationForField(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
    _IntrospectionData intr,
    FieldIntrospectionData fieldIntr,
  ) async {
    final field = fieldIntr.fieldDeclaration;
    final classDecl = fieldIntr.unaliasedTypeDeclaration;
    final optionName = _camelToKebabCase(field.identifier.name);

    if (classDecl.library.uri != Libraries.core) {
      if (await fieldIntr.nonNullableStaticType
          .isSubtypeOf(intr.staticTypes.Enum)) {
        return _getParserInitializationForEnum(
          builder,
          fieldIntr: fieldIntr,
          optionName: optionName,
        );
      }

      builder.report(
        Diagnostic(
          DiagnosticMessage(
            'An argument class can only have fields of core types, '
            '${fieldIntr.unaliasedTypeDeclaration.identifier.name} given. ',
            target: field.asDiagnosticTarget,
          ),
          Severity.error,
        ),
      );

      return const [];
    }

    switch (classDecl.identifier.name) {
      case 'String':
      case 'int':
      case 'double':
        return _getParserInitializationForString(
          field: field,
          optionName: optionName,
        );

      case 'bool':
        return _getParserInitializationForBool(
          builder,
          field: field,
          optionName: optionName,
        );
    }

    return ['// None for ${field.identifier.name}\n'];
  }

  List<Object> _getParserInitializationForString({
    required FieldDeclaration field,
    required String optionName,
  }) {
    return [
      //
      'parser.addOption(\n',
      '  "$optionName",\n',
      if (!field.hasInitializer && !field.type.isNullable)
        '  mandatory: true,\n',
      ');\n',
    ];
  }

  List<Object> _getParserInitializationForBool(
    MemberDeclarationBuilder builder, {
    required FieldDeclaration field,
    required String optionName,
  }) {
    if (field.type.isNullable) {
      builder.report(
        Diagnostic(
          DiagnosticMessage(
            'Boolean cannot be nullable.',
            target: field.asDiagnosticTarget,
          ),
          Severity.error,
        ),
      );

      return const [];
    }

    builder.report(
      Diagnostic(
        DiagnosticMessage(
          'Boolean must have a default value.',
          target: field.asDiagnosticTarget,
        ),
        Severity.error,
      ),
    );

    return const [];
  }

  Future<List<Object>> _getParserInitializationForEnum(
    MemberDeclarationBuilder builder, {
    required FieldIntrospectionData fieldIntr,
    required String optionName,
  }) async {
    final field = fieldIntr.fieldDeclaration;
    final enumIntr =
        await builder.introspectEnum(fieldIntr.unaliasedTypeDeclaration);
    final values = enumIntr.values.map((v) => v.name).toList(growable: false);

    return [
      //
      'parser.addOption(\n',
      '  "$optionName",\n',
      '  allowed: ${jsonEncode(values)},\n',
      if (!field.hasInitializer && !field.type.isNullable)
        '  mandatory: true,\n',
      ');\n',
    ];
  }

  List<Object> _getParserInitializationForHelp() {
    return [
      //
      'parser.addFlag(\n',
      '  "$_helpFlag",\n',
      '  abbr: "$_hFlag",\n',
      '  help: "Print this usage information.",\n',
      '  negatable: false,\n',
      ');\n',
    ];
  }

  Future<List<Object>> _getParse(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
    _IntrospectionData intr,
  ) async {
    final name = clazz.identifier.name;
    final c = intr.codes;

    return [
      //
      name, ' parse(', c.List, '<', c.String, '> argv) {\n',
      '  try {\n',
      '    final wrapped = _parseWrapped(argv);\n',
      '    return $name(\n',
      for (final fieldIntr in intr.fields.values)
        ...[...await _getConstructionParam(builder, intr, fieldIntr), ',\n']
            .indent(6),
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

  Future<List<Object>> _getConstructionParam(
    MemberDeclarationBuilder builder,
    _IntrospectionData intr,
    FieldIntrospectionData fieldIntr,
  ) async {
    final type = fieldIntr.unaliasedTypeDeclaration.identifier.name;
    final optionName = _camelToKebabCase(fieldIntr.name);

    switch (type) {
      case 'String':
        return [
          fieldIntr.name,
          ': wrapped.option(${jsonEncode(optionName)})!',
        ];

      case 'int':
      case 'double':
        final typeCode = switch (type) {
          'int' => intr.codes.int,
          'double' => intr.codes.double,
          _ => throw Exception(),
        };
        return [
          fieldIntr.name,
          ': ',
          typeCode,
          '.tryParse(wrapped.option(${jsonEncode(optionName)})!)',
          ' ?? (throw ',
          intr.codes.ArgumentError,
          '.value(\n',
          '  wrapped.option(${jsonEncode(optionName)}),\n',
          '  "$optionName",\n',
          '  "Cannot parse the value of \\"$optionName\\" into $type, \\"" + wrapped.option(${jsonEncode(optionName)})! + "\\" given.",\n',
          ')',
          ')',
        ];

      case 'bool':
        return [
          fieldIntr.name,
          ': wrapped.flag(${jsonEncode(optionName)})',
        ];
    }

    if (await fieldIntr.nonNullableStaticType
        .isSubtypeOf(intr.staticTypes.Enum)) {
      return [
        fieldIntr.name,
        ': ',
        fieldIntr.unaliasedTypeDeclaration.identifier,
        '.values.byName(wrapped.option(${jsonEncode(optionName)})!)',
      ];
    }

    throw Exception('Parsing of $type into an argument value is unimplemented');
  }

  List<Object> _getParseWrapped(_IntrospectionData intr) {
    final c = intr.codes;

    return [
      //
      c.ArgResults, ' _parseWrapped(', c.List, '<',
      c.String, '> argv) {\n',
      '  final results = parser.parse(argv);\n',
      '\n',
      '  if (results.flag("$_helpFlag")) {\n',
      '    _printUsage(', c.stdout, ');\n',
      '    ', c.exit, '(0);\n',
      '  }\n',
      '\n',
      '  for (final option in parser.options.values) {\n',
      '    if (option.mandatory && !results.wasParsed(option.name)) {\n',
      '      throw ', c.ArgumentError, '.value(\n',
      '        null,\n',
      '        option.name,\n',
      r'        "Option \"${option.name}\" is mandatory.",', '\n',
      '      );\n',
      '    }\n',
      '  }\n',
      '\n',
      '  return results;\n',
      '}\n',
    ];
  }

  List<Object> _getPrintUsage(_IntrospectionData intr) {
    return [
      //
      'void _printUsage(', intr.codes.IOSink, ' stream) {\n',
      '  stream.writeln(${jsonEncode(_getUsagePrefix())});\n',
      '  stream.writeln(parser.usage);\n',
      '}\n',
    ];
  }

  String _getUsagePrefix() {
    final buffer = StringBuffer();

    if (description != null) {
      buffer.writeln(description);
      buffer.writeln();
    }

    buffer.write('Usage:');
    if (executableName != null) {
      buffer.write(' $executableName');
    }
    buffer.write(' [arguments]'); // TODO(alexeyinkin): Don't if no arguments.

    return buffer.toString();
  }
}

class _IntrospectionData {
  _IntrospectionData({
    required this.codes,
    required this.fields,
    required this.staticTypes,
  });

  final Codes codes;
  final Map<String, FieldIntrospectionData> fields;
  final StaticTypes staticTypes;

  static Future<_IntrospectionData> fill(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {
    final ids = await ResolvedIdentifiers.fill(builder);
    final codes = Codes.fromResolvedIdentifiers(ids);

    final (fields, staticTypes) = await (
      builder.introspectType(clazz),
      StaticTypes.fill(builder, codes),
    ).wait;

    return _IntrospectionData(
      codes: codes,
      fields: fields,
      staticTypes: staticTypes,
    );
  }
}

String _camelToKebabCase(String input) {
  final buffer = StringBuffer();

  for (int i = 0; i < input.length; i++) {
    final char = input[i];
    if (char.toUpperCase() == char && char.toLowerCase() != char) {
      // Uppercase.
      if (i != 0) {
        buffer.write('-');
      }

      buffer.write(char.toLowerCase());
    } else {
      buffer.write(char);
    }
  }

  return buffer.toString();
}

extension _IterableExtension<T> on Iterable<T> {
  Iterable<T> alternateWith(T separator) {
    return expand((item) sync* {
      yield separator;
      yield item;
    }).skip(1);
  }
}
