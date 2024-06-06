// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs

import 'package:macros/macros.dart';

import 'resolved_identifiers.dart';

class Codes {
  Codes({
    required this.ArgParser,
    required this.ArgResults,
    required this.ArgumentError,
    required this.double,
    required this.Enum,
    required this.exit,
    required this.FormatException,
    required this.int,
    required this.IOSink,
    required this.List,
    required this.print,
    required this.stderr,
    required this.stdout,
    required this.String,
    required this.StringBuffer,
  });

  final NamedTypeAnnotationCode ArgParser;
  final NamedTypeAnnotationCode ArgResults;
  final NamedTypeAnnotationCode ArgumentError;
  final NamedTypeAnnotationCode double;
  final NamedTypeAnnotationCode Enum;
  final NamedTypeAnnotationCode exit;
  final NamedTypeAnnotationCode FormatException;
  final NamedTypeAnnotationCode int;
  final NamedTypeAnnotationCode IOSink;
  final NamedTypeAnnotationCode List;
  final NamedTypeAnnotationCode print;
  final NamedTypeAnnotationCode stderr;
  final NamedTypeAnnotationCode stdout;
  final NamedTypeAnnotationCode String;
  final NamedTypeAnnotationCode StringBuffer;

  factory Codes.fromResolvedIdentifiers(ResolvedIdentifiers ids) {
    return Codes(
      ArgParser: NamedTypeAnnotationCode(name: ids.ArgParser),
      ArgResults: NamedTypeAnnotationCode(name: ids.ArgResults),
      ArgumentError: NamedTypeAnnotationCode(name: ids.ArgumentError),
      double: NamedTypeAnnotationCode(name: ids.double),
      Enum: NamedTypeAnnotationCode(name: ids.Enum),
      exit: NamedTypeAnnotationCode(name: ids.exit),
      FormatException: NamedTypeAnnotationCode(name: ids.FormatException),
      int: NamedTypeAnnotationCode(name: ids.int),
      IOSink: NamedTypeAnnotationCode(name: ids.IOSink),
      List: NamedTypeAnnotationCode(name: ids.List),
      print: NamedTypeAnnotationCode(name: ids.print),
      stderr: NamedTypeAnnotationCode(name: ids.stderr),
      stdout: NamedTypeAnnotationCode(name: ids.stdout),
      String: NamedTypeAnnotationCode(name: ids.String),
      StringBuffer: NamedTypeAnnotationCode(name: ids.StringBuffer),
    );
  }
}
