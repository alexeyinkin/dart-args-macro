// ignore_for_file: public_member_api_docs

import 'package:macro_util/macro_util.dart';
import 'package:macros/macros.dart';

import 'arguments.dart';
import 'codes.dart';
import 'static_types.dart';

class IntrospectionData {
  IntrospectionData({
    required this.arguments,
    required this.clazz,
    required this.codes,
    required this.fields,
    required this.staticTypes,
  });

  final Arguments arguments;
  final ClassDeclaration clazz;
  final Codes codes;
  final Map<String, FieldIntrospectionData> fields;
  final StaticTypes staticTypes;
}
