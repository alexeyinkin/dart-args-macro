import 'package:macro_util/macro_util.dart';
import 'package:macros/macros.dart';

import 'argument.dart';
import 'resolved_identifiers.dart';
import 'static_types.dart';

class IntrospectionData {
  IntrospectionData({
    required this.arguments,
    required this.clazz,
    required this.fields,
    required this.ids,
    required this.staticTypes,
  });

  final Map<String, Argument> arguments;
  final ClassDeclaration clazz;
  final Map<String, FieldIntrospectionData> fields;
  final ResolvedIdentifiers ids;
  final StaticTypes staticTypes;
}
