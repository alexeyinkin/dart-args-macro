import 'package:macro_util/macro_util.dart';

import 'enum_introspection_data.dart';
import 'visitors/mock_data_object_generator.dart';
import 'visitors/visitor.dart';

/// An option or a flag to be parsed.
sealed class Argument {
  Argument({
    required this.intr,
    required this.optionName,
  });

  // ignore: public_member_api_docs
  final FieldIntrospectionData intr;

  /// The name for this option or flag.
  ///
  /// In most cases, it's produced by turning the field name to kebab case.
  final String optionName;

  /// Called by visitors that walk the argument lists
  /// to call the type-specific method on the visitor.
  R accept<R>(ArgumentVisitor<R> visitor);

  /// Whether this argument should be passed to the unnamed constructor
  /// of the data class.
  bool get isInConstructor =>
      !intr.fieldDeclaration.hasFinal || !intr.fieldDeclaration.hasInitializer;

  /// Whether this argument meets all requirements for its type.
  ///
  /// If any argument is not [isValid], the program will not build.
  /// An invalid argument may still be [isInConstructor].
  bool get isValid => true;
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

/// A boolean flag.
class BoolArgument extends ResolvedTypeArgument {
  // ignore: public_member_api_docs
  BoolArgument({
    required super.intr,
    required super.optionName,
  });

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitBool(this);
  }

  /// The Dart code to get the name for the flag.
  String get flagNameGetter {
    return [
      MockDataObjectGenerator.fieldName,
      '.',
      intr.name,
      ' ?? false',
      ' ? "no-$optionName"',
      ' : "$optionName"',
    ].join();
  }
}

/// A [double] argument.
class DoubleArgument extends ResolvedTypeArgument {
  // ignore: public_member_api_docs
  DoubleArgument({
    required super.intr,
    required super.optionName,
  });

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitDouble(this);
  }
}

/// An [Enum] argument.
class EnumArgument extends ResolvedTypeArgument {
  // ignore: public_member_api_docs
  EnumArgument({
    required super.intr,
    required super.optionName,
    required this.enumIntr,
  });

  // ignore: public_member_api_docs
  final EnumIntrospectionData enumIntr;

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitEnum(this);
  }
}

/// An [int] argument.
class IntArgument extends ResolvedTypeArgument {
  // ignore: public_member_api_docs
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
  // ignore: public_member_api_docs
  InvalidTypeArgument({
    required super.intr,
  }) : super(optionName: '',);

  @override
  bool get isValid => false;

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitInvalidType(this);
  }
}

/// A [List] or [Set] argument.
abstract class IterableArgument extends ResolvedTypeArgument {
  // ignore: public_member_api_docs
  IterableArgument({
    required super.intr,
    required super.optionName,
    required this.iterableType,
  });

  // ignore: public_member_api_docs
  final IterableType iterableType;
}

/// A List<String> or Set<String> argument.
class IterableStringArgument extends IterableArgument {
  // ignore: public_member_api_docs
  IterableStringArgument({
    required super.intr,
    required super.iterableType,
    required super.optionName,
  });

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitIterableString(this);
  }
}

/// A List<int> or Set<int> argument.
class IterableIntArgument extends IterableArgument {
  // ignore: public_member_api_docs
  IterableIntArgument({
    required super.intr,
    required super.iterableType,
    required super.optionName,
  });

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitIterableInt(this);
  }
}

/// A type of an [Iterable] supported for argument parsing.
enum IterableType {
  /// A [List].
  list,

  /// A [Set].
  set,
}

/// A [String] argument.
class StringArgument extends ResolvedTypeArgument {
  // ignore: public_member_api_docs
  StringArgument({
    required super.intr,
    required super.optionName,
  });

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitString(this);
  }
}
