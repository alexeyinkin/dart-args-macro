import 'package:common_macros/common_macros.dart';
import 'package:macro_util/macro_util.dart';
import 'package:macros/macros.dart';

import '../argument.dart';
import '../introspection_data.dart';
import 'positional_param_generator.dart';
import 'visitor.dart';

const _constructorName = 'withDefaults';

/// Generates code to create an instance of the data class that
/// does not overwrite the fields that have initializers.
///
/// This mock object is then used as the source of data
/// for options that were not passed.
///
/// The required fields are filled with dummy values of the respective types
/// since they will never be used because the actual values for them
/// will be parsed when constructing the end-instance of the data class.
class MockDataObjectGenerator extends ArgumentVisitor<List<Object>>
    with PositionalParamGenerator {
  // ignore: public_member_api_docs
  MockDataObjectGenerator(this.intr);

  @override
  final IntrospectionData intr;

  // ignore: public_member_api_docs
  static const fieldName = '_mockDataObject';

  /// Creates the constructor on the data class which does not have
  /// parameters for fields that have initializers
  /// thus keeping them from being overwritten.
  static Future<void> createMockConstructor(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {
    return const Constructor(
      name: _constructorName,
      skipInitialized: true,
    ).buildDeclarationsForClass(clazz, builder);
  }

  // ignore: public_member_api_docs
  List<Object> generate() {
    final name = intr.clazz.identifier.name;
    final arguments = intr.arguments.values.where(
      (a) =>
          a.intr.constructorOptionality ==
              FieldConstructorOptionality.required &&
          a.intr.constructorHandling ==
              FieldConstructorHandling.namedOrPositional,
    );

    return [
      'static final $fieldName = $name.$_constructorName(\n',
      for (final param in getPositionalParams()) ...[...param, ',\n'].indent(),
      for (final parts in arguments.map((argument) => argument.accept(this)))
        ...[...parts, ',\n'].indent(),
      ');\n',
    ];
  }

  @override
  List<Object> visitBool(BoolArgument argument) {
    // Bool fields must have initializers, so they never should be
    // in a mock object. However, if a user violates that, we want
    // our diagnostic and not a compile error, so return valid code.
    return [
      argument.intr.name,
      ': false',
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
      argument.intr.deAliasedTypeDeclaration.identifier,
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
  List<Object> visitInvalidType(InvalidTypeArgument argument) {
    return [
      argument.intr.name,
      ': _silenceUninitializedError',
    ];
  }

  @override
  List<Object> visitIterableDouble(IterableDoubleArgument argument) =>
      _visitIterable(argument);

  @override
  List<Object> visitIterableEnum(IterableEnumArgument argument) =>
      _visitIterable(argument);

  @override
  List<Object> visitIterableInt(IterableIntArgument argument) =>
      _visitIterable(argument);

  @override
  List<Object> visitIterableString(IterableStringArgument argument) =>
      _visitIterable(argument);

  @override
  List<Object> visitString(StringArgument argument) {
    return [
      argument.intr.name,
      ': ""',
    ];
  }

  List<Object> _visitIterable(IterableArgument argument) {
    switch (argument.iterableType) {
      case IterableType.list:
        return [
          argument.intr.name,
          ': const []',
        ];
      case IterableType.set:
        return [
          argument.intr.name,
          ': const {}',
        ];
    }
  }
}
