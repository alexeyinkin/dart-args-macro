import '../argument.dart';

/// The base for all objects that generate code specific to argument types.
abstract class ArgumentVisitor<R> {
  R visitInt(IntArgument argument);
  R visitInvalidType(InvalidTypeArgument argument);
  R visitString(StringArgument argument);
}
