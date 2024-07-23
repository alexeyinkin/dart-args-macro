// ignore_for_file: public_member_api_docs

import 'package:macros/macros.dart';

class EnumIntrospectionData {
  EnumIntrospectionData({
    required this.deAliasedTypeDeclaration,
    required this.values,
  });

  final TypeDeclaration deAliasedTypeDeclaration;
  final List<EnumConstantIntrospectionData> values;
}

class EnumConstantIntrospectionData {
  const EnumConstantIntrospectionData({
    required this.name,
  });

  final String name;
}

extension EnumIntrospectionExtension on DeclarationBuilder {
  Future<EnumIntrospectionData> introspectEnum(
    TypeDeclaration deAliasedTypeDeclaration,
  ) async {
    final fields = await fieldsOf(deAliasedTypeDeclaration);
    final values = (await Future.wait(fields.map(introspectEnumField)))
        .nonNulls
        .toList(growable: false);

    return EnumIntrospectionData(
      deAliasedTypeDeclaration: deAliasedTypeDeclaration,
      values: values,
    );
  }

  Future<EnumConstantIntrospectionData?> introspectEnumField(
    FieldDeclaration field,
  ) async {
    final type = field.type;

    if (type is NamedTypeAnnotation) {
      return null;
    }

    return EnumConstantIntrospectionData(
      name: field.identifier.name,
    );
  }
}
