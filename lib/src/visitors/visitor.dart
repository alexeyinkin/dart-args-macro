import '../argument.dart';

abstract class ArgumentVisitor<R> {
  R visitString(StringArgument argument);
  R visitInt(IntArgument argument);
  R visitDouble(DoubleArgument argument);
  R visitEnum(EnumArgument argument);
}
