import 'package:macros/macros.dart';

import 'libraries.dart';

class ResolvedIdentifiers {
  ResolvedIdentifiers({
    required this.ArgParser,
    required this.Enum,
    required this.int,
    required this.List,
    required this.String,
  });

  final Identifier ArgParser;
  final Identifier Enum;
  final Identifier int;
  final Identifier List;
  final Identifier String;

  static Future<ResolvedIdentifiers> resolve(
    MemberDeclarationBuilder builder,
  ) async {
    final (
      ArgParser,
      Enum,
      int,
      List,
      String,
    ) = await (
      builder.resolveIdentifier(Libraries.arg_parser, 'ArgParser'),
      builder.resolveIdentifier(Libraries.core, 'Enum'),
      builder.resolveIdentifier(Libraries.core, 'int'),
      builder.resolveIdentifier(Libraries.core, 'List'),
      builder.resolveIdentifier(Libraries.core, 'String'),
    ).wait;

    return ResolvedIdentifiers(
      ArgParser: ArgParser,
      Enum: Enum,
      int: int,
      List: List,
      String: String,
    );
  }
}
