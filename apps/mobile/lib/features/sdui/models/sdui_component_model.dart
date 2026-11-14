class SDUIComponentModel {
  final String id;
  final String type;
  final bool visible;
  final int order;
  final String? title;
  final String? subtitle;
  final Map<String, dynamic> props;

  SDUIComponentModel({
    required this.id,
    required this.type,
    required this.visible,
    required this.order,
    this.title,
    this.subtitle,
    this.props = const {},
  });

  factory SDUIComponentModel.fromJson(Map<String, dynamic> json) {
    return SDUIComponentModel(
      id: json['id'] as String? ?? 'comp_${DateTime.now().millisecondsSinceEpoch}',
      type: json['type'] as String? ?? 'unknown',
      visible: json['visible'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      props: json['props'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'visible': visible,
      'order': order,
      'title': title,
      'subtitle': subtitle,
      'props': props,
    };
  }
}
