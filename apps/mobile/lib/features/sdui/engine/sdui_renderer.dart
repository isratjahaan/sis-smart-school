import 'package:flutter/material.dart';
import '../models/sdui_screen_model.dart';
import 'sdui_registry.dart';

class SDUIRenderer extends StatelessWidget {
  final SDUIScreenModel screen;
  final Future<void> Function()? onRefresh;

  const SDUIRenderer({
    Key? key,
    required this.screen,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visibleComponents = screen.components.where((c) => c.visible).toList();

    Widget content = ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: visibleComponents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final compConfig = visibleComponents[index];
        return SDUIRegistry.buildComponent(compConfig);
      },
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    return content;
  }
}
