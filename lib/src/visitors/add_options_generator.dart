import 'dart:convert';

import '../argument.dart';
import '../introspection_data.dart';
import 'visitor.dart';

/// Generates '_addOptions' function of the parser
/// which adds all options to it.
class AddOptionsGenerator extends ArgumentVisitor<List<Object>> {
  AddOptionsGenerator(this.intr);

  final IntrospectionData intr;

  List<Object> generate() {
    return [
      //
      'void _addOptions() {\n',
      for (final argument in intr.arguments.values) ...[
        ...argument.accept(this),
        '\n',
      ],
      '}\n',
    ];
  }

  @override
  List<Object> visitInt(IntArgument argument) => _visitStringInt(argument);

  @override
  List<Object> visitInvalidType(InvalidTypeArgument argument) {
    return const [];
  }

  @override
  List<Object> visitIterableInt(IterableIntArgument argument) =>
      _visitIterableStringInt(argument);

  @override
  List<Object> visitIterableString(IterableStringArgument argument) =>
      _visitIterableStringInt(argument);

  @override
  List<Object> visitString(StringArgument argument) =>
      _visitStringInt(argument);

  List<Object> _visitStringInt(Argument argument) {
    return [
      //
      'parser.addOption(\n',
      '  ${jsonEncode(argument.optionName)},\n',
      '  mandatory: true,\n',
      ');\n',
    ];
  }

  List<Object> _visitIterableStringInt(IterableArgument argument) {
    return [
      //
      'parser.addMultiOption(\n',
      '  "${argument.optionName}",\n',
      ');\n',
    ];
  }
}
