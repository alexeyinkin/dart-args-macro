// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs

import 'package:macros/macros.dart';

import 'libraries.dart';

class ResolvedIdentifiers {
  ResolvedIdentifiers({
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

  final Identifier ArgParser;
  final Identifier ArgResults;
  final Identifier ArgumentError;
  final Identifier double;
  final Identifier Enum;
  final Identifier exit;
  final Identifier FormatException;
  final Identifier int;
  final Identifier IOSink;
  final Identifier List;
  final Identifier print;
  final Identifier stderr;
  final Identifier stdout;
  final Identifier String;
  final Identifier StringBuffer;

  static Future<ResolvedIdentifiers> fill(
    MemberDeclarationBuilder builder,
  ) async {
    final (
      ArgParser,
      ArgResults,
      exit,
      IOSink,
      List,
      print,
      stderr,
      stdout,
      String,
    ) = await (
      builder.resolveIdentifier(Libraries.arg_parser, 'ArgParser'),
      builder.resolveIdentifier(Libraries.arg_results, 'ArgResults'),
      builder.resolveIdentifier(Libraries.io, 'exit'),
      builder.resolveIdentifier(Libraries.io, 'IOSink'),
      builder.resolveIdentifier(Libraries.core, 'List'),
      builder.resolveIdentifier(Libraries.core, 'print'),
      builder.resolveIdentifier(Libraries.io, 'stderr'),
      builder.resolveIdentifier(Libraries.io, 'stdout'),
      builder.resolveIdentifier(Libraries.core, 'String'),
    ).wait;

    final (
      ArgumentError,
      double,
      Enum,
      FormatException,
      int,
      StringBuffer,
    ) = await (
      builder.resolveIdentifier(Libraries.core, 'ArgumentError'),
      builder.resolveIdentifier(Libraries.core, 'double'),
      builder.resolveIdentifier(Libraries.core, 'Enum'),
      builder.resolveIdentifier(Libraries.core, 'FormatException'),
      builder.resolveIdentifier(Libraries.core, 'int'),
      builder.resolveIdentifier(Libraries.core, 'StringBuffer')
    ).wait;

    return ResolvedIdentifiers(
      ArgParser: ArgParser,
      ArgResults: ArgResults,
      ArgumentError: ArgumentError,
      double: double,
      Enum: Enum,
      exit: exit,
      FormatException: FormatException,
      int: int,
      IOSink: IOSink,
      List: List,
      print: print,
      stderr: stderr,
      stdout: stdout,
      String: String,
      StringBuffer: StringBuffer,
    );
  }
}
