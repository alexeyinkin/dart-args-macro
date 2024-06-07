import 'package:macro_util/macro_util.dart';

import 'enum_introspection_data.dart';
import 'visitors/visitor.dart';

sealed class Argument {
  Argument({
    required this.intr,
    required this.optionName,
  });

  final FieldIntrospectionData intr;
  final String optionName;

  R accept<R>(ArgumentVisitor<R> visitor);
}

class DoubleArgument extends Argument {
  DoubleArgument({
    required super.intr,
    required super.optionName,
  });

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitDouble(this);
  }
}

class EnumArgument extends Argument {
  EnumArgument({
    required super.intr,
    required super.optionName,
    required this.enumIntr,
  });

  final EnumIntrospectionData enumIntr;

  @override
  R accept<R>(ArgumentVisitor<R> visitor) {
    return visitor.visitEnum(this);
  }
}

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
