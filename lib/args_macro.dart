import 'dart:async';
import 'dart:convert';

import 'package:common_macros/common_macros.dart';
import 'package:macro_util/macro_util.dart';
import 'package:macros/macros.dart';

final _coreLibrary = Uri.parse('dart:core');
final _ioLibrary = Uri.parse('dart:io');
final _argParserLibrary = Uri.parse('package:args/src/arg_parser.dart');
final _argResultsLibrary = Uri.parse('package:args/src/arg_results.dart');

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
    _augmentParser(clazz, builder, intr);
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
    builder.declareInType(
      DeclarationCode.fromParts(
        [
          //
          intr.stringCode, ' toDebugString() {\n',
          '  final buffer = ', intr.stringBufferCode, '();\n\n',
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

  void _augmentParser(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
    _IntrospectionData intr,
  ) {
    final parserName = _getParserName(clazz);

    builder.declareInLibrary(
      DeclarationCode.fromParts([
        //
        'augment class $parserName {\n',
        '  final parser = ', intr.argParserCode, '();\n',
        ..._getConstructor(clazz).indent(),
        ..._getInitializeParser(clazz, builder, intr).indent(),
        ..._getParse(clazz, intr).indent(),
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

  List<Object> _getInitializeParser(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
    _IntrospectionData intr,
  ) {
    return [
      //
      'void _initializeParser() {\n',
      ..._getParserInitialization(clazz, builder, intr).indent(),
      '}\n',
    ];
  }

  List<Object> _getParserInitialization(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
    _IntrospectionData intr,
  ) {
    final initializers = [
      for (final fieldIntr in intr.fields.values)
        _getParserInitializationForField(
          clazz,
          builder,
          intr,
          fieldIntr.fieldDeclaration,
        ),
      _getParserInitializationForHelp(),
    ];

    return initializers
        .alternateWith(['\n'])
        .expand((e) => e)
        .toList(growable: false);
  }

  List<Object> _getParserInitializationForField(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
    _IntrospectionData intr,
    FieldDeclaration field,
  ) {
    final name = field.identifier.name;
    final classDecl = intr.fields[name]!.unaliasedTypeDeclaration;

    if (classDecl.library.uri != _coreLibrary) {
      builder.report(
        Diagnostic(
          DiagnosticMessage(
            'An argument class can only have fields of core types',
            target: field.asDiagnosticTarget,
          ),
          Severity.error,
        ),
      );
      // TODO(alexeyinkin): Allow enum.
      return const [];
    }

    final optionName = _camelToKebabCase(field.identifier.name);

    switch (classDecl.identifier.name) {
      case 'String':
      case 'int':
      case 'double':
        return _getParserInitializationForString(
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

  List<Object> _getParse(ClassDeclaration clazz, _IntrospectionData intr) {
    final name = clazz.identifier.name;

    return [
      //
      name, ' parse(', intr.listCode, '<', intr.stringCode, '> argv) {\n',
      '  try {\n',
      '    final wrapped = _parseWrapped(argv);\n',
      '    return $name(\n',
      for (final fieldIntr in intr.fields.values)
        ...[..._getConstructionParam(intr, fieldIntr), '\n'].indent(6),
      '    );\n',
      '  } on ', intr.argumentErrorCode, ' catch (e) {\n',
      '    ', intr.stderrCode, '.writeln(e.message);', '\n',
      '    ', intr.stderrCode, '.writeln();', '\n',
      '    _printUsage(', intr.stderrCode, ');\n',
      '    ', intr.exitCode, '(64);\n',
      '  }\n',
      '}\n',
    ];
  }

  List<Object> _getConstructionParam(
    _IntrospectionData intr,
    FieldIntrospectionData fieldIntr,
  ) {
    final type = fieldIntr.unaliasedTypeDeclaration.identifier.name;
    final optionName = _camelToKebabCase(fieldIntr.name);

    switch (type) {
      case 'String':
        return [
          fieldIntr.name,
          ': wrapped.option(${jsonEncode(optionName)})!,',
        ];

      case 'int':
      case 'double':
        final typeCode = switch (type) {
          'int' => intr.intCode,
          'double' => intr.doubleCode,
          _ => throw Exception(),
        };
        return [
          fieldIntr.name,
          ': ',
          typeCode,
          '.tryParse(wrapped.option(${jsonEncode(optionName)})!)',
          ' ?? (throw ',
          intr.argumentErrorCode,
          '.value(\n',
          '  wrapped.option(${jsonEncode(optionName)}),\n',
          '  "$optionName",\n',
          '  "Cannot parse the value of \\"$optionName\\" into $type, \\"" + wrapped.option(${jsonEncode(optionName)})! + "\\" given.",\n',
          ')',
          '),',
        ];
    }

    throw Exception('Parsing of $type into an argument value is unimplemented');
  }

  List<Object> _getParseWrapped(_IntrospectionData intr) {
    return [
      //
      intr.argResultsCode, ' _parseWrapped(', intr.listCode, '<',
      intr.stringCode, '> argv) {\n',
      '  final results = parser.parse(argv);\n',
      '\n',
      '  if (results.flag("$_helpFlag")) {\n',
      '    _printUsage(', intr.stdoutCode, ');\n',
      '    ', intr.exitCode, '(0);\n',
      '  }\n',
      '\n',
      '  for (final option in parser.options.values) {\n',
      '    if (option.mandatory && !results.wasParsed(option.name)) {\n',
      '      throw ', intr.argumentErrorCode, '.value(\n',
      '        null,\n',
      '        option.name,\n',
      r'        "Option \"${option.name}\" is mandatory.",', '\n',
      '      );\n',
      // '      ', intr.stderrCode,
      // r'.writeln("Option \"${option.name}\" is mandatory.");', '\n',
      // '      ', intr.stderrCode, '.writeln();', '\n',
      // '      _printUsage(', intr.stderrCode, ');\n',
      // '      ', intr.exitCode, '(64);\n',
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
      'void _printUsage(', intr.ioSinkCode, ' stream) {\n',
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
    //
    required this.argParserCode,
    required this.argResultsCode,
    required this.argumentErrorCode,
    required this.doubleCode,
    required this.exitCode,
    required this.intCode,
    required this.ioSinkCode,
    required this.listCode,
    required this.printCode,
    required this.stderrCode,
    required this.stdoutCode,
    required this.stringBufferCode,
    required this.stringCode,

    //
    required this.fields,
  });

  final NamedTypeAnnotationCode argParserCode;
  final NamedTypeAnnotationCode argResultsCode;
  final NamedTypeAnnotationCode argumentErrorCode;
  final NamedTypeAnnotationCode doubleCode;
  final NamedTypeAnnotationCode exitCode;
  final NamedTypeAnnotationCode intCode;
  final NamedTypeAnnotationCode ioSinkCode;
  final NamedTypeAnnotationCode listCode;
  final NamedTypeAnnotationCode printCode;
  final NamedTypeAnnotationCode stderrCode;
  final NamedTypeAnnotationCode stdoutCode;
  final NamedTypeAnnotationCode stringBufferCode;
  final NamedTypeAnnotationCode stringCode;

  final Map<String, FieldIntrospectionData> fields;

  static Future<_IntrospectionData> fill(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {
    final (
      argParse,
      argResults,
      exit,
      ioSink,
      list,
      print,
      stderr,
      stdout,
      string,
    ) = await (
      builder.resolveIdentifier(_argParserLibrary, 'ArgParser'),
      builder.resolveIdentifier(_argResultsLibrary, 'ArgResults'),
      builder.resolveIdentifier(_ioLibrary, 'exit'),
      builder.resolveIdentifier(_ioLibrary, 'IOSink'),
      builder.resolveIdentifier(_coreLibrary, 'List'),
      builder.resolveIdentifier(_coreLibrary, 'print'),
      builder.resolveIdentifier(_ioLibrary, 'stderr'),
      builder.resolveIdentifier(_ioLibrary, 'stdout'),
      builder.resolveIdentifier(_coreLibrary, 'String'),
    ).wait;

    final (argumentError, doublee, intt, stringBuffer) = await (
      builder.resolveIdentifier(_coreLibrary, 'ArgumentError'),
      builder.resolveIdentifier(_coreLibrary, 'double'),
      builder.resolveIdentifier(_coreLibrary, 'int'),
      builder.resolveIdentifier(_coreLibrary, 'StringBuffer')
    ).wait;

    return _IntrospectionData(
      //
      argParserCode: NamedTypeAnnotationCode(name: argParse),
      argResultsCode: NamedTypeAnnotationCode(name: argResults),
      argumentErrorCode: NamedTypeAnnotationCode(name: argumentError),
      doubleCode: NamedTypeAnnotationCode(name: doublee),
      exitCode: NamedTypeAnnotationCode(name: exit),
      intCode: NamedTypeAnnotationCode(name: intt),
      ioSinkCode: NamedTypeAnnotationCode(name: ioSink),
      listCode: NamedTypeAnnotationCode(name: list),
      printCode: NamedTypeAnnotationCode(name: print),
      stderrCode: NamedTypeAnnotationCode(name: stderr),
      stdoutCode: NamedTypeAnnotationCode(name: stdout),
      stringBufferCode: NamedTypeAnnotationCode(name: stringBuffer),
      stringCode: NamedTypeAnnotationCode(name: string),

      fields: await FieldIntrospectionData.introspectType(clazz, builder),
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

// // To ignore deprecated_member_use in once location only.
// extension on DeclarationBuilder {
//   Future<Identifier> resolveId(Uri library, String name) {
//     // ignore: deprecated_member_use
//     return resolveIdentifier(library, name);
//   }
// }
