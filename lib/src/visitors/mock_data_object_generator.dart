import 'package:common_macros/common_macros.dart';
import 'package:macro_util/macro_util.dart';
import 'package:macros/macros.dart';

import '../argument.dart';
import '../introspection_data.dart';
import 'visitor.dart';

const _constructorName = 'withDefaults';

class MockDataObjectGenerator extends ArgumentVisitor<List<Object>> {
  MockDataObjectGenerator(this.clazz, this.intr);

  final ClassDeclaration clazz;
  final IntrospectionData intr;

  static const fieldName = '_mockDataObject';

  static Future<void> createMockConstructor(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {
    return const Constructor(
      name: _constructorName,
      skipInitialized: true,
    ).buildDeclarationsForClass(clazz, builder);
  }

  List<Object> generate() {
    final name = clazz.identifier.name;
    final arguments = intr.arguments.arguments.values
        .where((a) => !a.intr.fieldDeclaration.hasInitializer);

    return [
      'late final $fieldName = $name.$_constructorName(\n',
      for (final parts in arguments.map((argument) => argument.accept(this)))
        ...[...parts, ',\n'].indent(),
      ');\n',
    ];
  }

  @override
  List<Object> visitDouble(DoubleArgument argument) {
    return [
      argument.intr.name,
      ': 0',
    ];
  }

  @override
  List<Object> visitEnum(EnumArgument argument) {
    return [
      argument.intr.name,
      ': ',
      argument.intr.unaliasedTypeDeclaration.identifier,
      '.values.first',
    ];
  }

  @override
  List<Object> visitInt(IntArgument argument) {
    return [
      argument.intr.name,
      ': 0',
    ];
  }

  @override
  List<Object> visitString(StringArgument argument) {
    return [
      argument.intr.name,
      ': ""',
    ];
  }
}
