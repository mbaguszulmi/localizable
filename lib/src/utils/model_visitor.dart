import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';

class ModelVisitor extends SimpleElementVisitor<void> {
  late String className;
  late bool isAbstract;
  final fields = <String, dynamic>{};
  final fieldsValue = <String, dynamic>{};

  @override
  void visitConstructorElement(ConstructorElement element) {
    final elementReturnType = element.type.returnType.toString();
    className = elementReturnType.replaceFirst('*', '');
  }

  @override
  void visitFieldElement(FieldElement element) {
    final elementType = element.type.toString();
    dynamic value;
    if (element.computeConstantValue() != null) {
      if (element.name == 'translations') {
        value = element.computeConstantValue()!.toMapValue()!.map(
            (key, value) => MapEntry(
                key!.toStringValue()!,
                value!.toMapValue()!.map((key2, value2) =>
                    MapEntry(key2!.toStringValue()!, value2!.toStringValue()!))));
      } else if (element.name == 'defaultLocale') {
        value = element.computeConstantValue()!.toStringValue();
      }
    }

    fields[element.name] = elementType.replaceFirst('*', '');
    fieldsValue[element.name] = value;
  }

  @override
  void visitClassElement(ClassElement element) {
    super.visitClassElement(element);

    isAbstract = element.isAbstract;
  }
}
