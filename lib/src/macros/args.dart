import 'dart:async';

import 'package:common_macros/common_macros.dart';
import 'package:macro_util/macro_util.dart';
import 'package:macros/macros.dart';

import '../argument.dart';
import '../introspection_data.dart';
import '../resolved_identifiers.dart';
import '../util.dart';
import '../visitors/add_options_generator.dart';
import '../visitors/parse_generator.dart';

/// Creates a command line argument parser from your data class.
macro class Args implements ClassTypesMacro, ClassDeclarationsMacro {
  const Args();

  @override
  Future<void> buildTypesForClass(
    ClassDeclaration clazz,
    ClassTypeBuilder builder,
  ) async {
    final name = clazz.identifier.name;
    final parserName = _getParserName(clazz);

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

    await _declareConstructor(clazz, builder);
    _augmentParser(builder, intr);
  }

  Future<void> _declareConstructor(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {
    await const Constructor().buildDeclarationsForClass(clazz, builder);
  }

  void _augmentParser(
    MemberDeclarationBuilder builder,
    IntrospectionData intr,
  ) {
    final parserName = _getParserName(intr.clazz);

    builder.declareInLibrary(
      DeclarationCode.fromParts([
        //
        'augment class $parserName {\n',
        '  final parser = ', intr.ids.ArgParser, '();\n',
        ..._getConstructor(intr.clazz),
        ...AddOptionsGenerator(intr).generate(),
        ...ParseGenerator(intr).generate(),
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
      '}\n',
    ];
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
  final ids = await ResolvedIdentifiers.resolve(builder);
  final fields = await builder.introspectFields(clazz);
  final arguments = await _fieldsToArguments(fields, builder);

  return IntrospectionData(
    arguments: arguments,
    clazz: clazz,
    fields: fields,
    ids: ids,
  );
}

Future<Map<String, Argument>> _fieldsToArguments(
  Map<String, FieldIntrospectionData> fields,
  DeclarationBuilder builder,
) async {
  final futures = <String, Future<Argument>>{};

  for (final entry in fields.entries) {
    futures[entry.key] = _fieldToArgument(
      entry.value as ResolvedFieldIntrospectionData,
      builder: builder,
    );
  }

  return waitMap(futures);
}

Future<Argument> _fieldToArgument(
  ResolvedFieldIntrospectionData fieldIntr, {
  required DeclarationBuilder builder,
}) async {
  final typeDecl = fieldIntr.unaliasedTypeDeclaration;
  final optionName = _camelToKebabCase(fieldIntr.name);
  final typeName = typeDecl.identifier.name;

  switch (typeName) {
    case 'int':
      return IntArgument(
        intr: fieldIntr,
        optionName: optionName,
      );

    case 'String':
      return StringArgument(
        intr: fieldIntr,
        optionName: optionName,
      );
  }

  throw Exception();
}
