import 'package:macro_util/macro_util.dart';

import 'enum_introspection_data.dart';
import 'visitors/mock_data_object_generator.dart';
import 'visitors/visitor.dart';

/// An option or a flag to be parsed.
sealed class Argument {
  Argument({
    required this.intr,
    required this.isValid,
    required this.optionName,
  });

  // ignore: public_member_api_docs
  final FieldIntrospectionData intr;

  /// Whether this argument meets all requirements for its type.
  ///
  /// If any argument is not [isValid], the program will not build.
  /// An invalid argument may still be [isInConstructor].
  final bool isValid;

  /// The name for this option or flag.
  ///
  /// In most cases, it's produced by turning the field name to kebab case.
  final String optionName;

  /// Called by visitors that walk the argument lists
  /// to call the type-specific method on the visitor.
  R accept<R>(ArgumentVisitor<R> visitor);

  /// Whether this argument should be passed to the unnamed constructor
  /// of the data class.
  ///
  /// This argument may be not [isValid] but still required in the constructor
  /// because the macro that generates constructors is not aware
  /// of the argument semantics.
  /// To avoid compile errors, this is tested when generating a call
  /// to the constructor.
  bool get isInConstructor =>
      !intr.fieldDeclaration.hasFinal || !intr.fieldDeclaration.hasInitializer;
}

/// A boolean flag.
class BoolArgument extends Argument {
  // ignore: public_member_api_docs
  BoolArgument({
    required super.intr,
    required super.isValid,
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
class DoubleArgument extends Argument {
  // ignore: public_member_api_docs
  DoubleArgument({
    required super.intr,
    required super.isValid,
    required super.optionName,
  });

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitDouble(this);
  }
}

/// An [Enum] argument.
class EnumArgument extends Argument {
  // ignore: public_member_api_docs
  EnumArgument({
    required super.intr,
    required super.isValid,
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
class IntArgument extends Argument {
  // ignore: public_member_api_docs
  IntArgument({
    required super.intr,
    required super.isValid,
    required super.optionName,
  });

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitInt(this);
  }
}

/// A List<String> argument.
class ListStringArgument extends Argument {
  // ignore: public_member_api_docs
  ListStringArgument({
    required super.intr,
    required super.isValid,
    required super.optionName,
  });

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitListString(this);
  }
}

/// A [String] argument.
class StringArgument extends Argument {
  // ignore: public_member_api_docs
  StringArgument({
    required super.intr,
    required super.isValid,
    required super.optionName,
  });

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitString(this);
  }
}
