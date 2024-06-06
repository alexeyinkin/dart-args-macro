// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs

import 'package:macros/macros.dart';

import 'codes.dart';

class StaticTypes {
  StaticTypes({
    required this.Enum,
  });

  final StaticType Enum;

  static Future<StaticTypes> fill(
    MemberDeclarationBuilder builder,
    Codes codes,
  ) async {
    final Enum = await builder.resolve(codes.Enum);

    return StaticTypes(
      Enum: Enum,
    );
  }
}
