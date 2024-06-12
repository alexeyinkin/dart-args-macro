import '../identifiers.dart';
import 'visitor.dart';

/// Generates positional parameters for constructors of the data class.
mixin PositionalParamGenerator<R> on ArgumentVisitor<R> {
  // ignore: public_member_api_docs
  List<List<Object>> getPositionalParams() {
    final result = <List<Object>>[];

    for (final field in intr.fields.values) {
      if (field.fieldDeclaration.hasStatic) {
        continue;
      }
      if (!field.name.startsWith('_')) {
        continue;
      }

      result.add([
        Identifiers.silenceUninitializedError,
        '()',
      ]);
    }

    return result;
  }
}
