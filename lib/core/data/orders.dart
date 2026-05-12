import 'models.dart';
import 'products.dart';

final List<Address> initialAddresses = [
  const Address(
    id: 'addr-1',
    label: 'Home',
    recipientName: 'Saymum Azim',
    phoneNumber: '01711223344',
    district: 'Dhaka',
    upazila: 'Dhanmondi',
    area: 'Road 5',
    houseFlat: 'House 12',
    roadStreet: 'Road 5',
    landmark: 'Near Rabindra Sarobar',
    isDefault: true,
  ),
  const Address(
    id: 'addr-2',
    label: 'Office',
    recipientName: 'Saymum Azim',
    phoneNumber: '01711223344',
    district: 'Dhaka',
    upazila: 'Tejgaon',
    area: 'Industrial Area',
    houseFlat: 'Polytechnic Market',
    roadStreet: '45 No Lane',
  ),
];

final Rider initialRider = const Rider(
  name: 'Rasel Mia',
  phone: '01788990011',
  rating: 4.8,
);

final List<AppOrder> initialOrders = [
  AppOrder(
    id: '#ORD-20260401-101',
    status: OrderStatus.delivered,
    paymentMethod: PaymentMethod.cod,
    paymentStatus: 'paid',
    items: [
      AppOrderItem(id: 'oi-1', product: initialMedicines[0], quantity: 2),
      AppOrderItem(id: 'oi-2', product: initialMedicines[8], quantity: 1),
    ],
    subtotal: 128,
    discount: 12,
    deliveryCharge: 0,
    cashbackUsed: 0,
    total: 116,
    placedAt: DateTime(2026, 4, 1, 9, 0),
    deliveryAddress: initialAddresses.first,
    timeline: [
      AppOrderTimeline(
        status: 'Placed',
        time: DateTime(2026, 4, 1, 9, 0),
        completed: true,
      ),
      AppOrderTimeline(
        status: 'Confirmed',
        time: DateTime(2026, 4, 1, 9, 15),
        completed: true,
      ),
      AppOrderTimeline(
        status: 'Processing',
        time: DateTime(2026, 4, 1, 10, 30),
        completed: true,
      ),
      AppOrderTimeline(
        status: 'Dispatched',
        time: DateTime(2026, 4, 1, 13, 0),
        completed: true,
      ),
      AppOrderTimeline(
        status: 'Out for Delivery',
        time: DateTime(2026, 4, 1, 16, 0),
        completed: true,
      ),
      AppOrderTimeline(
        status: 'Delivered',
        time: DateTime(2026, 4, 1, 18, 15),
        completed: true,
      ),
    ],
    rider: initialRider,
    userId: 'user_1',
  ),
];

