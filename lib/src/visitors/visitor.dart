import '../argument.dart';
import '../introspection_data.dart';

/// The base for all objects that generate code specific to argument types.
abstract class ArgumentVisitor<R> {
  // ignore: public_member_api_docs
  IntrospectionData get intr;

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
  R visitIterableDouble(IterableDoubleArgument argument);

  // ignore: public_member_api_docs
  R visitIterableInt(IterableIntArgument argument);

  // ignore: public_member_api_docs
  R visitIterableString(IterableStringArgument argument);

  // ignore: public_member_api_docs
  R visitString(StringArgument argument);
}
