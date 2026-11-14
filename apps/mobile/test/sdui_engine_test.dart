import 'package:flutter_test/flutter_test.dart';
import 'package:sis_smart_school/features/sdui/models/sdui_screen_model.dart';
import 'package:sis_smart_school/features/sdui/models/sdui_component_model.dart';
import 'package:sis_smart_school/features/sdui/engine/sdui_registry.dart';

void main() {
  group('Server-Driven UI (SDUI) Engine Tests', () {
    test('Correctly parses JSON screen layout and orders components', () {
      final json = {
        'screenId': 'student_home',
        'version': 2,
        'title': 'Test Screen',
        'components': [
          {'id': 'c2', 'type': 'result_card', 'order': 2, 'visible': true},
          {'id': 'c1', 'type': 'welcome_banner', 'order': 1, 'visible': true},
          {'id': 'c3', 'type': 'attendance_card', 'order': 3, 'visible': false},
        ],
      };

      final model = SDUIScreenModel.fromJson(json);

      expect(model.screenId, 'student_home');
      expect(model.version, 2);
      expect(model.components.length, 3);
      // Components must be sorted by order
      expect(model.components[0].id, 'c1');
      expect(model.components[1].id, 'c2');
      expect(model.components[2].id, 'c3');
      expect(model.components[2].visible, false);
    });

    test('Registry returns safe fallback widget for unknown component types', () {
      final unknownComp = SDUIComponentModel(
        id: 'c_unknown',
        type: 'unsupported_future_widget',
        visible: true,
        order: 1,
      );

      final widget = SDUIRegistry.buildComponent(unknownComp);
      expect(widget, isNotNull);
    });
  });
}
