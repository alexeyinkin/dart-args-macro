// ignore_for_file: public_member_api_docs

import 'package:collection/collection.dart';
import 'package:macros/macros.dart';

class EnumIntrospectionData {
  EnumIntrospectionData({
    required this.unaliasedTypeDeclaration,
    required this.values,
  });

  final TypeDeclaration unaliasedTypeDeclaration;
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
    TypeDeclaration unaliasedTypeDeclaration,
  ) async {
    final fields = await fieldsOf(unaliasedTypeDeclaration);
    final values = (await Future.wait(fields.map(introspectEnumField)))
        .whereNotNull()
        .toList(growable: false);

    return EnumIntrospectionData(
      unaliasedTypeDeclaration: unaliasedTypeDeclaration,
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
