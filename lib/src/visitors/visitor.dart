import '../argument.dart';

/// The base for all objects that generate code specific to argument types.
abstract class ArgumentVisitor<R> {
  // ignore: public_member_api_docs
  R visitBool(BoolArgument argument);

  // ignore: public_member_api_docs
  R visitDouble(DoubleArgument argument);

  // ignore: public_member_api_docs
  R visitEnum(EnumArgument argument);

  // ignore: public_member_api_docs
  R visitInt(IntArgument argument);

  // ignore: public_member_api_docs
  R visitInvalidType(InvalidTypeArgument argument);

  // ignore: public_member_api_docs
  R visitIterableString(IterableStringArgument argument);

  // ignore: public_member_api_docs
  R visitString(StringArgument argument);
}
