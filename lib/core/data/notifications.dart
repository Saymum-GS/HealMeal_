import 'models.dart';

final List<AppNotification> initialNotifications = [
  AppNotification(
    id: 'n1',
    title: 'Order dispatched',
    body: 'Your AppOrder #ORD-20260405-001 is on the way with rider Rasel Mia.',
    time: DateTime(2026, 4, 5, 14, 30),
    type: 'order',
  ),
  AppNotification(
    id: 'n2',
    title: 'Prescription approved',
    body: 'Your uploaded prescription has been approved by our pharmacist.',
    time: DateTime(2026, 4, 4, 11, 15),
    type: 'prescription',
  ),
  AppNotification(
    id: 'n3',
    title: 'Lab booking confirmed',
    body: 'Dengue Package sample collection is scheduled for tomorrow morning.',
    time: DateTime(2026, 4, 3, 20, 0),
    type: 'lab',
    read: true,
  ),
  AppNotification(
    id: 'n4',
    title: 'Flash sale live',
    body: 'Save up to 83% on selected healthcare essentials today.',
    time: DateTime(2026, 4, 2, 9, 10),
    type: 'offer',
  ),
];

