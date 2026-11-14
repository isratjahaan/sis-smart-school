import 'sdui_component_model.dart';

class SDUIScreenModel {
  final String screenId;
  final int version;
  final String? title;
  final List<SDUIComponentModel> components;
  final String? updatedAt;

  SDUIScreenModel({
    required this.screenId,
    required this.version,
    this.title,
    required this.components,
    this.updatedAt,
  });

  factory SDUIScreenModel.fromJson(Map<String, dynamic> json) {
    final rawComps = json['components'] as List<dynamic>? ?? [];
    final comps = rawComps
        .map((c) => SDUIComponentModel.fromJson(c as Map<String, dynamic>))
        .toList();

    // Sort by order
    comps.sort((a, b) => a.order.compareTo(b.order));

    return SDUIScreenModel(
      screenId: json['screenId'] as String? ?? 'unknown',
      version: json['version'] as int? ?? 1,
      title: json['title'] as String?,
      components: comps,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'screenId': screenId,
      'version': version,
      'title': title,
      'components': components.map((c) => c.toJson()).toList(),
      'updatedAt': updatedAt,
    };
  }
}
