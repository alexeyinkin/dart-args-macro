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

/// An [int] argument.
class IntArgument extends Argument {
  IntArgument({
    required super.intr,
    required super.optionName,
  });

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitInt(this);
  }
}

/// A [String] argument.
class StringArgument extends Argument {
  StringArgument({
    required super.intr,
    required super.optionName,
  });

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitString(this);
  }
}
