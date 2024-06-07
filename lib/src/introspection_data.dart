import 'arguments.dart';
import 'codes.dart';
import 'static_types.dart';

class IntrospectionData {
  IntrospectionData({
    required this.codes,
    required this.arguments,
    required this.staticTypes,
  });

  final Codes codes;
  final Arguments arguments;
  final StaticTypes staticTypes;
}