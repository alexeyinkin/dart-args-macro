// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs

import 'package:macros/macros.dart';

import 'resolved_identifiers.dart';

class StaticTypes {
  StaticTypes({
    required this.Enum,
  });

  final StaticType Enum;

  static Future<StaticTypes> resolve(
    MemberDeclarationBuilder builder,
    ResolvedIdentifiers ids,
  ) async {
    final Enum = await builder.resolve(NamedTypeAnnotationCode(name: ids.Enum));

    return StaticTypes(
      Enum: Enum,
    );
  }
}
