import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_provider.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_service.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'slot_provider_test.mocks.dart';

@GenerateMocks([SlotService])
void main() {
  group('SlotProvider tests', () {
    late MockSlotService mockSlotService;

    setUp(() {
      mockSlotService = MockSlotService();
    });

    test('getNextAvailableSlots should return a list of slots', () async {
      var slotProvider = SlotProvider(
        slotService: mockSlotService,
        gym: Gym(id: '1'),
        activity: Activity(),
      );

      var slotList = [
        Slot(start: DateTime(10, 10)),
        Slot(start: DateTime(11, 10)),
      ];

      when(
        mockSlotService.fetchUpcomingSlots(any, any, any),
      ).thenAnswer((_) async => slotList);

      var res = await slotProvider.getUpcomingSlots();
      expect(res, slotList);
    });
  });
}
