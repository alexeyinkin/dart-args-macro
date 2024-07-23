import 'package:macro_util/macro_util.dart';

import 'visitors/visitor.dart';

/// An option or a flag to be parsed.
sealed class Argument {
  Argument({
    required this.intr,
    required this.optionName,
  });

  final FieldIntrospectionData intr;

  /// The name for this option or flag.
  ///
  /// In most cases, it's produced by turning the field name to kebab case.
  final String optionName;

  /// Called by visitors that walk the argument lists
  /// to call the type-specific method on the visitor.
  R accept<R>(ArgumentVisitor<R> visitor);
}

/// An argument backed by a field with a successfully resolved type.
abstract class ResolvedTypeArgument extends Argument {
  // ignore: public_member_api_docs
  ResolvedTypeArgument({
    required ResolvedFieldIntrospectionData super.intr,
    required super.optionName,
  });

  @override
  ResolvedFieldIntrospectionData get intr =>
      super.intr as ResolvedFieldIntrospectionData;
}

/// An [int] argument.
class IntArgument extends ResolvedTypeArgument {
  IntArgument({
    required super.intr,
    required super.optionName,
  });

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitInt(this);
  }
}

/// A placeholder [Argument] for any invalid field.
///
/// Used to pass a value in the constructors to silence the error
/// of an uninitialized field.
class InvalidTypeArgument extends Argument {
  InvalidTypeArgument({
    required super.intr,
  }) : super(
          optionName: '',
        );

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitInvalidType(this);
  }
}

/// A [String] argument.
class StringArgument extends ResolvedTypeArgument {
  StringArgument({
    required super.intr,
    required super.optionName,
  });

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitString(this);
  }
}
