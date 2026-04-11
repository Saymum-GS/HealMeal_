import 'mock_models.dart';
import 'mock_products.dart';

final List<MockAddress> mockAddresses = [
  const MockAddress(
    id: 'addr-1',
    label: 'Home',
    recipientName: 'Arif Hasan',
    phoneNumber: '01811987654',
    district: 'Dhaka',
    upazila: 'Dhanmondi',
    area: 'Road 5',
    houseFlat: 'House 12',
    roadStreet: 'Road 5',
    landmark: 'Near Rabindra Sarobar',
    isDefault: true,
  ),
  const MockAddress(
    id: 'addr-2',
    label: 'Office',
    recipientName: 'Arif Hasan',
    phoneNumber: '01811987654',
    district: 'Dhaka',
    upazila: 'Tejgaon',
    area: 'Industrial Area',
    houseFlat: 'Polytechnic Market',
    roadStreet: '45 No Lane',
  ),
];

final MockRider mockRider = const MockRider(
  name: 'Rasel Mia',
  phone: '01788990011',
  rating: 4.8,
);

final List<MockOrder> mockOrders = [
  MockOrder(
    id: '#ORD-20260401-101',
    status: OrderStatus.delivered,
    paymentMethod: PaymentMethod.cod,
    paymentStatus: 'paid',
    items: [
      MockOrderItem(id: 'oi-1', product: mockMedicines[0], quantity: 2),
      MockOrderItem(id: 'oi-2', product: mockMedicines[8], quantity: 1),
    ],
    subtotal: 128,
    discount: 12,
    deliveryCharge: 0,
    cashbackUsed: 0,
    total: 116,
    placedAt: DateTime(2026, 4, 1, 9, 0),
    deliveryAddress: mockAddresses.first,
    timeline: [
      MockTimeline(
        status: 'Placed',
        time: DateTime(2026, 4, 1, 9, 0),
        completed: true,
      ),
      MockTimeline(
        status: 'Confirmed',
        time: DateTime(2026, 4, 1, 9, 15),
        completed: true,
      ),
      MockTimeline(
        status: 'Processing',
        time: DateTime(2026, 4, 1, 10, 30),
        completed: true,
      ),
      MockTimeline(
        status: 'Dispatched',
        time: DateTime(2026, 4, 1, 13, 0),
        completed: true,
      ),
      MockTimeline(
        status: 'Out for Delivery',
        time: DateTime(2026, 4, 1, 16, 0),
        completed: true,
      ),
      MockTimeline(
        status: 'Delivered',
        time: DateTime(2026, 4, 1, 18, 15),
        completed: true,
      ),
    ],
    rider: mockRider,
  ),
  MockOrder(
    id: '#ORD-20260405-001',
    status: OrderStatus.dispatched,
    paymentMethod: PaymentMethod.bkash,
    paymentStatus: 'paid',
    items: [
      MockOrderItem(id: 'oi-3', product: mockMedicines[1], quantity: 1),
      MockOrderItem(id: 'oi-4', product: mockMedicines[15], quantity: 2),
    ],
    subtotal: 850,
    discount: 115,
    deliveryCharge: 0,
    cashbackUsed: 0,
    total: 735,
    placedAt: DateTime(2026, 4, 5, 10, 0),
    deliveryAddress: mockAddresses.first,
    timeline: [
      MockTimeline(
        status: 'Placed',
        time: DateTime(2026, 4, 5, 10, 0),
        completed: true,
      ),
      MockTimeline(
        status: 'Confirmed',
        time: DateTime(2026, 4, 5, 10, 20),
        completed: true,
      ),
      MockTimeline(
        status: 'Processing',
        time: DateTime(2026, 4, 5, 11, 0),
        completed: true,
      ),
      MockTimeline(
        status: 'Dispatched',
        time: DateTime(2026, 4, 5, 13, 30),
        completed: true,
      ),
      MockTimeline(
        status: 'Out for Delivery',
        time: DateTime(2026, 4, 5, 16, 0),
        completed: false,
      ),
      MockTimeline(
        status: 'Delivered',
        time: DateTime(2026, 4, 5, 18, 0),
        completed: false,
      ),
    ],
    rider: mockRider,
  ),
  MockOrder(
    id: '#ORD-20260404-012',
    status: OrderStatus.processing,
    paymentMethod: PaymentMethod.cod,
    paymentStatus: 'pending',
    items: [MockOrderItem(id: 'oi-5', product: mockMedicines[10], quantity: 1)],
    subtotal: 3490,
    discount: 300,
    deliveryCharge: 60,
    cashbackUsed: 30,
    total: 3220,
    placedAt: DateTime(2026, 4, 4, 12, 0),
    deliveryAddress: mockAddresses.last,
    timeline: [
      MockTimeline(
        status: 'Placed',
        time: DateTime(2026, 4, 4, 12, 0),
        completed: true,
      ),
      MockTimeline(
        status: 'Confirmed',
        time: DateTime(2026, 4, 4, 12, 40),
        completed: true,
      ),
      MockTimeline(
        status: 'Processing',
        time: DateTime(2026, 4, 4, 15, 0),
        completed: true,
      ),
      MockTimeline(
        status: 'Dispatched',
        time: DateTime(2026, 4, 4, 17, 0),
        completed: false,
      ),
      MockTimeline(
        status: 'Out for Delivery',
        time: DateTime(2026, 4, 4, 19, 0),
        completed: false,
      ),
      MockTimeline(
        status: 'Delivered',
        time: DateTime(2026, 4, 4, 21, 0),
        completed: false,
      ),
    ],
  ),
  MockOrder(
    id: '#ORD-20260406-088',
    status: OrderStatus.placed,
    paymentMethod: PaymentMethod.nagad,
    paymentStatus: 'paid',
    items: [MockOrderItem(id: 'oi-6', product: mockMedicines[18], quantity: 1)],
    subtotal: 1290,
    discount: 0,
    deliveryCharge: 0,
    cashbackUsed: 0,
    total: 1290,
    placedAt: DateTime(2026, 4, 6, 8, 30),
    deliveryAddress: mockAddresses.first,
    timeline: [
      MockTimeline(
        status: 'Placed',
        time: DateTime(2026, 4, 6, 8, 30),
        completed: true,
      ),
      MockTimeline(
        status: 'Confirmed',
        time: DateTime(2026, 4, 6, 9, 0),
        completed: false,
      ),
      MockTimeline(
        status: 'Processing',
        time: DateTime(2026, 4, 6, 10, 0),
        completed: false,
      ),
      MockTimeline(
        status: 'Dispatched',
        time: DateTime(2026, 4, 6, 12, 0),
        completed: false,
      ),
      MockTimeline(
        status: 'Out for Delivery',
        time: DateTime(2026, 4, 6, 14, 0),
        completed: false,
      ),
      MockTimeline(
        status: 'Delivered',
        time: DateTime(2026, 4, 6, 18, 0),
        completed: false,
      ),
    ],
  ),
  MockOrder(
    id: '#ORD-20260402-330',
    status: OrderStatus.cancelled,
    paymentMethod: PaymentMethod.card,
    paymentStatus: 'refunded',
    items: [MockOrderItem(id: 'oi-7', product: mockMedicines[5], quantity: 1)],
    subtotal: 310,
    discount: 10,
    deliveryCharge: 60,
    cashbackUsed: 0,
    total: 360,
    placedAt: DateTime(2026, 4, 2, 15, 0),
    deliveryAddress: mockAddresses.last,
    timeline: [
      MockTimeline(
        status: 'Placed',
        time: DateTime(2026, 4, 2, 15, 0),
        completed: true,
      ),
      MockTimeline(
        status: 'Confirmed',
        time: DateTime(2026, 4, 2, 15, 20),
        completed: true,
      ),
      MockTimeline(
        status: 'Cancelled',
        time: DateTime(2026, 4, 2, 16, 0),
        completed: true,
      ),
    ],
  ),
];
