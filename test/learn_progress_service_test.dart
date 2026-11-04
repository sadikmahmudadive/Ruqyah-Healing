import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/services/learn_progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('marks a lesson done and remembers it after a reload', () async {
    final service = LearnProgressService();
    await service.load();
    expect(service.isDone('l1'), isFalse);

    await service.setDone('l1', true);
    expect(service.isDone('l1'), isTrue);

    final reloaded = LearnProgressService();
    await reloaded.load();
    expect(reloaded.isDone('l1'), isTrue);
    expect(reloaded.doneIds, {'l1'});
  });

  test('unmarking removes it', () async {
    SharedPreferences.setMockInitialValues({
      'learn_done': ['l1', 'l2'],
    });
    final service = LearnProgressService();
    await service.load();
    expect(service.doneIds, {'l1', 'l2'});

    await service.setDone('l1', false);
    expect(service.isDone('l1'), isFalse);

    final reloaded = LearnProgressService();
    await reloaded.load();
    expect(reloaded.doneIds, {'l2'});
  });

  test('setLastOpened persists', () async {
    final service = LearnProgressService();
    await service.load();
    expect(service.lastOpenedId, isNull);

    await service.setLastOpened('l3');
    expect(service.lastOpenedId, 'l3');

    final reloaded = LearnProgressService();
    await reloaded.load();
    expect(reloaded.lastOpenedId, 'l3');
  });

  test('notifies listeners on change', () async {
    final service = LearnProgressService();
    await service.load();
    var calls = 0;
    service.addListener(() => calls++);

    await service.setDone('l1', true);
    expect(calls, 1);
    await service.setLastOpened('l1');
    expect(calls, 2);

    // No-op changes stay quiet.
    await service.setDone('l1', true);
    await service.setLastOpened('l1');
    expect(calls, 2);
  });
}
