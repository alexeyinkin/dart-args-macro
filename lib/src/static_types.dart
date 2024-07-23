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
