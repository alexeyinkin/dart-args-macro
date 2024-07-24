import 'package:macros/macros.dart';

import 'libraries.dart';

class ResolvedIdentifiers {
  ResolvedIdentifiers({
    required this.ArgParser,
    required this.ArgResults,
    required this.Enum,
    required this.exit,
    required this.int,
    required this.IOSink,
    required this.List,
    required this.stdout,
    required this.String,
  });

  final Identifier ArgParser;
  final Identifier ArgResults;
  final Identifier Enum;
  final Identifier exit;
  final Identifier int;
  final Identifier IOSink;
  final Identifier List;
  final Identifier stdout;
  final Identifier String;

  static Future<ResolvedIdentifiers> resolve(
    MemberDeclarationBuilder builder,
  ) async {
    final (
      ArgParser,
      ArgResults,
      Enum,
      exit,
      int,
      IOSink,
      List,
      stdout,
      String,
    ) = await (
      builder.resolveIdentifier(Libraries.arg_parser, 'ArgParser'),
      builder.resolveIdentifier(Libraries.arg_results, 'ArgResults'),
      builder.resolveIdentifier(Libraries.core, 'Enum'),
      builder.resolveIdentifier(Libraries.io, 'exit'),
      builder.resolveIdentifier(Libraries.core, 'int'),
      builder.resolveIdentifier(Libraries.io, 'IOSink'),
      builder.resolveIdentifier(Libraries.core, 'List'),
      builder.resolveIdentifier(Libraries.io, 'stdout'),
      builder.resolveIdentifier(Libraries.core, 'String'),
    ).wait;

    return ResolvedIdentifiers(
      ArgParser: ArgParser,
      ArgResults: ArgResults,
      Enum: Enum,
      exit: exit,
      int: int,
      IOSink: IOSink,
      List: List,
      stdout: stdout,
      String: String,
    );
  }
}
