import 'package:equatable/equatable.dart';

enum UserRole { patient, pharmacist, rider, admin, labTech, business }

enum Gender { male, female, other }

enum OrderStatus {
  placed,
  confirmed,
  processing,
  dispatched,
  outForDelivery,
  delivered,
  cancelled,
}

enum PrescriptionStatus { pending, approved, rejected }

enum PaymentMethod { cod, bkash, nagad, rocket, card, wallet }

enum LabBookingStatus { upcoming, processing, completed, cancelled }

class MockProduct extends Equatable {
  const MockProduct({
    required this.id,
    required this.name,
    required this.slug,
    required this.brandName,
    required this.categorySlug,
    required this.mrp,
    required this.salePrice,
    required this.discountPercent,
    required this.reviewCount,
    required this.rating,
    required this.isRxRequired,
    required this.isFlashSale,
    required this.inStock,
    required this.imageUrl,
    required this.deliveryBadge,
    this.gallery = const <String>[],
    this.cashback = 0,
    this.stockLeft = 12,
    this.description = '',
    this.howToUse = '',
    this.sideEffects = '',
    this.storage = '',
  });

  final String id;
  final String name;
  final String slug;
  final String brandName;
  final String categorySlug;
  final double mrp;
  final double salePrice;
  final int discountPercent;
  final int reviewCount;
  final double rating;
  final bool isRxRequired;
  final bool isFlashSale;
  final bool inStock;
  final String imageUrl;
  final String deliveryBadge;
  final List<String> gallery;
  final double cashback;
  final int stockLeft;
  final String description;
  final String howToUse;
  final String sideEffects;
  final String storage;

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    slug,
    brandName,
    categorySlug,
    mrp,
    salePrice,
  ];
}

class MockLabTest extends Equatable {
  const MockLabTest({
    required this.id,
    required this.name,
    required this.slug,
    required this.includes,
    required this.mrp,
    required this.salePrice,
    required this.discountPercent,
    required this.reportHours,
    required this.preparation,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String slug;
  final List<String> includes;
  final double mrp;
  final double salePrice;
  final int discountPercent;
  final int reportHours;
  final String preparation;
  final String imageUrl;

  @override
  List<Object?> get props => <Object?>[id, name];
}

abstract class MockUser {
  String get id;

  String get name;

  String get phone;

  String get role;
}

class RoleUser extends Equatable implements MockUser {
  const RoleUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    this.extra = const <String, String>{},
  });

  @override
  final String id;

  @override
  final String name;

  @override
  final String phone;

  @override
  final String role;

  final String? email;
  final Map<String, String> extra;

  @override
  List<Object?> get props => <Object?>[id, role, phone];
}

class MockAddress extends Equatable {
  const MockAddress({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phoneNumber,
    required this.district,
    required this.upazila,
    required this.area,
    required this.houseFlat,
    required this.roadStreet,
    this.landmark,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String recipientName;
  final String phoneNumber;
  final String district;
  final String upazila;
  final String area;
  final String houseFlat;
  final String roadStreet;
  final String? landmark;
  final bool isDefault;

  String get fullAddress =>
      '$houseFlat, $roadStreet, $area, $upazila, $district${landmark == null || landmark!.isEmpty ? '' : ' • $landmark'}';

  MockAddress copyWith({
    String? id,
    String? label,
    String? recipientName,
    String? phoneNumber,
    String? district,
    String? upazila,
    String? area,
    String? houseFlat,
    String? roadStreet,
    String? landmark,
    bool? isDefault,
  }) {
    return MockAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      district: district ?? this.district,
      upazila: upazila ?? this.upazila,
      area: area ?? this.area,
      houseFlat: houseFlat ?? this.houseFlat,
      roadStreet: roadStreet ?? this.roadStreet,
      landmark: landmark ?? this.landmark,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    label,
    recipientName,
    phoneNumber,
    district,
    upazila,
    area,
  ];
}

class MockOrderItem extends Equatable {
  const MockOrderItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  final String id;
  final MockProduct product;
  final int quantity;

  double get subtotal => product.salePrice * quantity;

  @override
  List<Object?> get props => <Object?>[id, product, quantity];
}

class MockTimeline extends Equatable {
  const MockTimeline({
    required this.status,
    required this.time,
    required this.completed,
  });

  final String status;
  final DateTime time;
  final bool completed;

  @override
  List<Object?> get props => <Object?>[status, time, completed];
}

class MockRider extends Equatable {
  const MockRider({
    required this.name,
    required this.phone,
    required this.rating,
  });

  final String name;
  final String phone;
  final double rating;

  @override
  List<Object?> get props => <Object?>[name, phone, rating];
}

class MockOrder extends Equatable {
  const MockOrder({
    required this.id,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryCharge,
    required this.cashbackUsed,
    required this.total,
    required this.placedAt,
    required this.deliveryAddress,
    required this.timeline,
    this.rider,
  });

  final String id;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final String paymentStatus;
  final List<MockOrderItem> items;
  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double cashbackUsed;
  final double total;
  final DateTime placedAt;
  final MockAddress deliveryAddress;
  final List<MockTimeline> timeline;
  final MockRider? rider;

  @override
  List<Object?> get props => <Object?>[id, status, total, placedAt];
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.dispatched:
        return 'Dispatched';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cod:
        return 'Cash on Delivery';
      case PaymentMethod.bkash:
        return 'bKash';
      case PaymentMethod.nagad:
        return 'Nagad';
      case PaymentMethod.rocket:
        return 'Rocket';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.wallet:
        return 'Wallet';
    }
  }
}

class MockNotification extends Equatable {
  const MockNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime time;
  final String type;
  final bool read;

  MockNotification copyWith({bool? read}) {
    return MockNotification(
      id: id,
      title: title,
      body: body,
      time: time,
      type: type,
      read: read ?? this.read,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, title, time, type, read];
}
