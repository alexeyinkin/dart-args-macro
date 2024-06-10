import 'dart:async';
import 'dart:convert';

import 'package:common_macros/common_macros.dart';
import 'package:macro_util/macro_util.dart';
import 'package:macros/macros.dart';

import '../argument.dart';
import '../arguments.dart';
import '../codes.dart';
import '../enum_introspection_data.dart';
import '../identifiers.dart';
import '../introspection_data.dart';
import '../libraries.dart';
import '../resolved_identifiers.dart';
import '../static_types.dart';
import '../util.dart';
import '../visitors/add_options_generator.dart';
import '../visitors/mock_data_object_generator.dart';
import '../visitors/parse_generator.dart';
import '../visitors/to_debug_string_generator.dart';

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
    final intr = await _introspect(clazz, builder);

    await _declareConstructors(clazz, builder);
    _declareToDebugString(builder, intr);
    _augmentParser(clazz, builder, intr);
  }

  Future<void> _declareConstructors(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {
    await Future.wait([
      //
      const Constructor().buildDeclarationsForClass(clazz, builder),
      MockDataObjectGenerator.createMockConstructor(clazz, builder),
    ]);
  }

  void _declareToDebugString(
    MemberDeclarationBuilder builder,
    IntrospectionData intr,
  ) {
    builder.declareInType(
      DeclarationCode.fromParts(
        ToDebugStringGenerator(intr).generate().indent(),
      ),
    );
  }

  void _augmentParser(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
    IntrospectionData intr,
  ) {
    final parserName = _getParserName(clazz);

    builder.declareInLibrary(
      DeclarationCode.fromParts([
        //
        'augment class $parserName {\n',
        '  final parser = ', intr.codes.ArgParser, '();\n',
        '  static ${Identifiers.silenceUninitializedError}() {}\n',
        ...MockDataObjectGenerator(clazz, intr).generate().indent(),
        ..._getConstructor(clazz).indent(),
        ...AddOptionsGenerator(intr).generate().indent(),
        ..._getAddHelpFlag().indent(),
        ...ParseGenerator(clazz, intr).generate().indent(),
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
      '  _addOptions();\n',
      '  _addHelpFlag();\n',
      '}\n',
    ];
  }

  List<Object> _getAddHelpFlag() {
    return [
      //
      'void _addHelpFlag() {\n',
      '  parser.addFlag(\n',
      '    "$_helpFlag",\n',
      '    abbr: "$_hFlag",\n',
      '    help: "Print this usage information.",\n',
      '    negatable: false,\n',
      '  );\n',
      '}\n',
    ];
  }

  List<Object> _getParseWrapped(IntrospectionData intr) {
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

  List<Object> _getPrintUsage(IntrospectionData intr) {
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

Future<IntrospectionData> _introspect(
  ClassDeclaration clazz,
  MemberDeclarationBuilder builder,
) async {
  final ids = await ResolvedIdentifiers.fill(builder);
  final codes = Codes.fromResolvedIdentifiers(ids);

  final (fields, staticTypes) = await (
    builder.introspectFields(clazz),
    StaticTypes.fill(builder, codes),
  ).wait;

  final arguments = await _fieldsToArguments(
    fields,
    builder: builder,
    staticTypes: staticTypes,
  );

  return IntrospectionData(
    codes: codes,
    arguments: arguments,
    staticTypes: staticTypes,
  );
}

Future<Arguments> _fieldsToArguments(
  Map<String, FieldIntrospectionData> fields, {
  required DeclarationBuilder builder,
  required StaticTypes staticTypes,
}) async {
  final futures = <String, Future<Argument?>>{};

  for (final entry in fields.entries) {
    futures[entry.key] = _fieldToArgument(
      entry.value,
      builder: builder,
      staticTypes: staticTypes,
    );
  }

  final arguments = (await waitMap(futures)).whereNotNull();
  return Arguments(
    arguments: arguments,
  );
}

Future<Argument?> _fieldToArgument(
  FieldIntrospectionData fieldIntr, {
  required DeclarationBuilder builder,
  required StaticTypes staticTypes,
}) async {
  final field = fieldIntr.fieldDeclaration;
  final target = field.asDiagnosticTarget;

  void unsupportedType() {
    builder.reportError(
      'The only allowed types are: String, int, double, bool, Enum, '
      'List<String>, List<int>, List<double>, List<bool>, List<Enum>, '
      'Set<String>, Set<int>, Set<double>, Set<bool>, Set<Enum>.',
      target: target,
    );
  }

  if (fieldIntr is! ResolvedFieldIntrospectionData) {
    unsupportedType();
    return InvalidTypeArgument(intr: fieldIntr);
  }

  final type = field.type;
  final typeDecl = fieldIntr.unaliasedTypeDeclaration;
  final optionName = _camelToKebabCase(fieldIntr.name);

  if (type is! NamedTypeAnnotation) {
    unsupportedType();
    return null;
  }

  bool isValid = true;

  if (field.hasInitializer && field.hasFinal) {
    builder.reportError(
      'A field with an initializer cannot be final '
      'because it needs to be overwritten when parsing the argument.',
      target: target,
    );

    isValid = false;
  }

  switch (typeDecl.identifier.name) {
    case 'bool':
    case 'List':
    case 'Set':
      // These have more specific messages for nullability later.
      break;

    default:
      if (field.hasInitializer && type.isNullable) {
        builder.reportError(
          'A field with an initializer must be non-nullable '
          'because nullability and the default value '
          'are mutually exclusive ways to handle a missing value.',
          target: target,
        );

        isValid = false;
      }
  }

  if (typeDecl.library.uri != Libraries.core) {
    if (!isValid) {
      return InvalidTypeArgument(intr: fieldIntr);
    }

    if (await fieldIntr.nonNullableStaticType.isSubtypeOf(staticTypes.Enum)) {
      return EnumArgument(
        intr: fieldIntr,
        optionName: optionName,
        enumIntr:
            await builder.introspectEnum(fieldIntr.unaliasedTypeDeclaration),
      );
    }

    builder.reportError(
      'An argument class can only have fields of core types, '
      '${fieldIntr.unaliasedTypeDeclaration.identifier.name} given.',
      target: target,
    );

    return null; // TODO: Test a custom class.
  }

  final typeName = typeDecl.identifier.name;
  switch (typeName) {
    case 'bool':
      if (type.isNullable) {
        builder.reportError(
          'Boolean cannot be nullable.',
          target: target,
        );

        isValid = false;
      }

      if (!field.hasInitializer) {
        builder.reportError(
          'Boolean must have a default value.',
          target: target,
        );

        isValid = false;
      }

      if (!isValid) {
        return InvalidTypeArgument(intr: fieldIntr);
      }

      return BoolArgument(
        intr: fieldIntr,
        optionName: optionName,
      );

    case 'double':
      if (!isValid) {
        return InvalidTypeArgument(intr: fieldIntr);
      }

      return DoubleArgument(
        intr: fieldIntr,
        optionName: optionName,
      );

    case 'int':
      if (!isValid) {
        return InvalidTypeArgument(intr: fieldIntr);
      }

      return IntArgument(
        intr: fieldIntr,
        optionName: optionName,
      );

    case 'List':
    case 'Set':
      if (type.isNullable) {
        builder.reportError(
          'A $typeName cannot be nullable because it is just empty '
          'when no options with this name are passed.',
          target: target,
        );

        isValid = false;
      }

      final paramType = type.typeArguments.firstOrNull;
      if (paramType == null) {
        builder.reportError(
          'A $typeName requires a type parameter: '
          '$typeName<String>, $typeName<int>, $typeName<double>, '
          '$typeName<bool>, $typeName<Enum>.',
          target: target,
        );

        return InvalidTypeArgument(intr: fieldIntr);
      }

      if (paramType is! NamedTypeAnnotation) {
        unsupportedType();
        return InvalidTypeArgument(intr: fieldIntr);
      }

      final paramTypeDecl = await builder.unaliasedTypeDeclarationOf(paramType);

      // TODO: Enum?
      // if (paramTypeDecl.library.uri != Libraries.core) {
      //
      // }

      if (!isValid) {
        return InvalidTypeArgument(intr: fieldIntr);
      }

      switch (paramTypeDecl.identifier.name) {
        case 'int':
          return IterableIntArgument(
            intr: fieldIntr,
            iterableType: IterableType.values.byName(typeName.toLowerCase()),
            optionName: optionName,
          );

        case 'String':
          return IterableStringArgument(
            intr: fieldIntr,
            iterableType: IterableType.values.byName(typeName.toLowerCase()),
            optionName: optionName,
          );
      }

    case 'String':
      if (!isValid) {
        return InvalidTypeArgument(intr: fieldIntr);
      }

      return StringArgument(
        intr: fieldIntr,
        optionName: optionName,
      );
  }

  unsupportedType();
  return InvalidTypeArgument(intr: fieldIntr);
}
