import 'package:macro_util/macro_util.dart';

import '../identifiers.dart';
import 'visitor.dart';

/// Generates positional parameters for constructors of the data class.
mixin PositionalParamGenerator<R> on ArgumentVisitor<R> {
  // ignore: public_member_api_docs
  List<List<Object>> getPositionalParams() {
    final result = <List<Object>>[];
    final fields = intr.fields.values.where(
      (f) => f.constructorHandling == FieldConstructorHandling.positional,
    );

    for (final _ in fields) {
      result.add([
        Identifiers.silenceUninitializedError,
        '()',
      ]);
    }

    return result;
  }
}
