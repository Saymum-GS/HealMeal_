import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum UserRole { 
  patient, 
  pharmacist, 
  rider, 
  admin, 
  labTech, 
  business;

  String get id => name;
  
  String get label {
    switch (this) {
      case UserRole.patient: return 'Patient';
      case UserRole.pharmacist: return 'Pharmacist';
      case UserRole.rider: return 'Rider';
      case UserRole.admin: return 'Admin';
      case UserRole.labTech: return 'Lab Tech';
      case UserRole.business: return 'Business';
    }
  }

  String get homeRoute {
    switch (this) {
      case UserRole.patient: return '/home';
      case UserRole.pharmacist: return '/pharmacist';
      case UserRole.rider: return '/rider';
      case UserRole.admin: return '/admin';
      case UserRole.labTech: return '/lab-tech';
      case UserRole.business: return '/account/business';
    }
  }
}

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

enum LabBookingStatus { upcoming, processing, collected, resultReady, completed, cancelled }

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.brandName,
    required this.genericName,
    required this.dosageForm,
    required this.strength,
    required this.categorySlug,
    required this.mrp,
    required this.salePrice,
    this.discountPercent = 0,
    this.reviewCount = 0,
    this.rating = 5.0,
    this.isRxRequired = false,
    this.isFlashSale = false,
    this.inStock = true,
    required this.imageUrl,
    this.deliveryBadge = 'Standard Delivery',
    this.gallery = const <String>[],
    this.cashback = 0,
    this.stockLeft = 12,
    this.description = '',
    this.indications = '',
    this.howToUse = '',
    this.sideEffects = '',
    this.storage = '',
    this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Product(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      slug: map['slug'] ?? '',
      brandName: map['brandName'] ?? '',
      genericName: map['genericName'] ?? '',
      dosageForm: map['dosageForm'] ?? '',
      strength: map['strength'] ?? '',
      categorySlug: map['categorySlug'] ?? '',
      mrp: (map['mrp'] ?? 0.0).toDouble(),
      salePrice: (map['salePrice'] ?? 0.0).toDouble(),
      discountPercent: (map['discountPercent'] ?? 0).toInt(),
      reviewCount: (map['reviewCount'] ?? 0).toInt(),
      rating: (map['rating'] ?? 5.0).toDouble(),
      isRxRequired: map['isRxRequired'] ?? false,
      isFlashSale: map['isFlashSale'] ?? false,
      inStock: map['inStock'] ?? true,
      imageUrl: map['imageUrl'] ?? '',
      deliveryBadge: map['deliveryBadge'] ?? 'Standard Delivery',
      gallery: List<String>.from(map['gallery'] ?? []),
      cashback: (map['cashback'] ?? 0.0).toDouble(),
      stockLeft: (map['stockLeft'] ?? 0).toInt(),
      description: map['description'] ?? '',
      indications: map['indications'] ?? '',
      howToUse: map['howToUse'] ?? '',
      sideEffects: map['sideEffects'] ?? '',
      storage: map['storage'] ?? '',
      createdAt: map['createdAt'] is DateTime 
          ? map['createdAt'] 
          : (map['createdAt'] != null ? (map['createdAt'] as dynamic).toDate() : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'brandName': brandName,
      'genericName': genericName,
      'dosageForm': dosageForm,
      'strength': strength,
      'categorySlug': categorySlug,
      'mrp': mrp,
      'salePrice': salePrice,
      'discountPercent': discountPercent,
      'reviewCount': reviewCount,
      'rating': rating,
      'isRxRequired': isRxRequired,
      'isFlashSale': isFlashSale,
      'inStock': inStock,
      'imageUrl': imageUrl,
      'deliveryBadge': deliveryBadge,
      'gallery': gallery,
      'cashback': cashback,
      'stockLeft': stockLeft,
      'description': description,
      'indications': indications,
      'howToUse': howToUse,
      'sideEffects': sideEffects,
      'storage': storage,
      'createdAt': createdAt,
    };
  }

  final String id;
  final String name;
  final String slug;
  final String brandName;
  final String genericName;
  final String dosageForm;
  final String strength;
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
  final String indications;
  final String howToUse;
  final String sideEffects;
  final String storage;
  final DateTime? createdAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    slug,
    brandName,
    genericName,
    mrp,
    salePrice,
  ];
}

class LabTest extends Equatable {
  const LabTest({
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
    this.createdAt,
  });

  factory LabTest.fromMap(Map<String, dynamic> map, [String? docId]) {
    return LabTest(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      slug: map['slug'] ?? '',
      includes: List<String>.from(map['includes'] ?? []),
      mrp: (map['mrp'] ?? 0.0).toDouble(),
      salePrice: (map['salePrice'] ?? 0.0).toDouble(),
      discountPercent: (map['discountPercent'] ?? 0).toInt(),
      reportHours: map['reportHours'] ?? '',
      preparation: map['preparation'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as dynamic).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'includes': includes,
      'mrp': mrp,
      'salePrice': salePrice,
      'discountPercent': discountPercent,
      'reportHours': reportHours,
      'preparation': preparation,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }

  final String id;
  final String name;
  final String slug;
  final List<String> includes;
  final double mrp;
  final double salePrice;
  final int discountPercent;
  final String reportHours;
  final String preparation;
  final String imageUrl;
  final DateTime? createdAt;

  @override
  List<Object?> get props => <Object?>[id, name];
}

class LabBooking extends Equatable {
  final String id;
  final String testId;
  final String testName;
  final String patientName;
  final String age;
  final String gender;
  final DateTime selectedDate;
  final String timeSlot;
  final LabBookingStatus status;
  final double price;
  final DateTime createdAt;
  final String userId;
  final String? reportUrl;

  const LabBooking({
    required this.id,
    required this.testId,
    required this.testName,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.selectedDate,
    required this.timeSlot,
    this.status = LabBookingStatus.upcoming,
    required this.price,
    required this.createdAt,
    required this.userId,
    this.reportUrl,
  });

  factory LabBooking.fromMap(Map<String, dynamic> map, [String? docId]) {
    return LabBooking(
      id: docId ?? map['id'] ?? '',
      testId: map['testId'] ?? '',
      testName: map['testName'] ?? '',
      patientName: map['patientName'] ?? '',
      age: map['age'] ?? '',
      gender: map['gender'] ?? '',
      selectedDate: map['selectedDate'] is DateTime 
          ? map['selectedDate'] 
          : (map['selectedDate'] != null ? (map['selectedDate'] as dynamic).toDate() : DateTime.now()),
      timeSlot: map['timeSlot'] ?? '',
      status: LabBookingStatus.values.firstWhere(
              (e) => e.name == (map['status'] ?? ''), 
              orElse: () => LabBookingStatus.upcoming
            ),
      price: (map['price'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] is DateTime 
          ? map['createdAt'] 
          : (map['createdAt'] != null ? (map['createdAt'] as dynamic).toDate() : DateTime.now()),
      userId: map['userId'] ?? '',
      reportUrl: map['reportUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'testId': testId,
      'testName': testName,
      'patientName': patientName,
      'age': age,
      'gender': gender,
      'selectedDate': selectedDate,
      'timeSlot': timeSlot,
      'status': status.name,
      'price': price,
      'createdAt': createdAt,
      'userId': userId,
      'reportUrl': reportUrl,
    };
  }

  @override
  List<Object?> get props => [id, testName, patientName, status];
}

class Prescription extends Equatable {
  final String id;
  final String userId;
  final String imageUrl;
  final PrescriptionStatus status;
  final DateTime uploadedAt;
  final String? fileName;
  final List<String> mappedProductIds;

  const Prescription({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.status,
    required this.uploadedAt,
    this.fileName,
    this.mappedProductIds = const [],
  });

  factory Prescription.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Prescription(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      status: PrescriptionStatus.values.firstWhere(
              (e) => e.name == (map['status'] ?? ''), 
              orElse: () => PrescriptionStatus.pending
            ),
      uploadedAt: map['uploadedAt'] is DateTime 
          ? map['uploadedAt'] 
          : (map['uploadedAt'] != null ? (map['uploadedAt'] as dynamic).toDate() : DateTime.now()),
      fileName: map['fileName'],
      mappedProductIds: List<String>.from(map['mappedProductIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'status': status.name,
      'uploadedAt': uploadedAt,
      'fileName': fileName,
      'mappedProductIds': mappedProductIds,
    };
  }

  @override
  List<Object?> get props => [id, userId, status, uploadedAt];
}

abstract class AppUserInterface {
  String get id;
  String get name;
  String get phone;
  String get role;
}

class AppUser extends Equatable implements AppUserInterface {
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    this.photoUrl,
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
  final String? photoUrl;
  final Map<String, dynamic> extra;

  factory AppUser.fromMap(Map<String, dynamic> map, [String? docId]) {
    return AppUser(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? UserRole.patient.name,
      email: map['email'],
      photoUrl: map['photoUrl'],
      extra: Map<String, dynamic>.from(map['extra'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'email': email,
      'photoUrl': photoUrl,
      'extra': extra,
    };
  }

  @override
  List<Object?> get props => <Object?>[id, role, phone];
}

class Address extends Equatable {
  const Address({
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

  factory Address.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Address(
      id: docId ?? map['id'] ?? '',
      label: map['label'] ?? '',
      recipientName: map['recipientName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      district: map['district'] ?? '',
      upazila: map['upazila'] ?? '',
      area: map['area'] ?? '',
      houseFlat: map['houseFlat'] ?? '',
      roadStreet: map['roadStreet'] ?? '',
      landmark: map['landmark'],
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'district': district,
      'upazila': upazila,
      'area': area,
      'houseFlat': houseFlat,
      'roadStreet': roadStreet,
      'landmark': landmark,
      'isDefault': isDefault,
    };
  }

  Address copyWith({
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
    return Address(
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

class AppOrderItem extends Equatable {
  const AppOrderItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  final String id;
  final Product product;
  final int quantity;

  double get subtotal => product.salePrice * quantity;

  factory AppOrderItem.fromMap(Map<String, dynamic> map) {
    return AppOrderItem(
      id: map['id'] ?? '',
      product: Product.fromMap(map['product'] ?? {}),
      quantity: (map['quantity'] ?? 1).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  @override
  List<Object?> get props => <Object?>[id, product, quantity];
}

class AppOrderTimeline extends Equatable {
  const AppOrderTimeline({
    required this.status,
    required this.time,
    required this.completed,
  });

  final String status;
  final DateTime time;
  final bool completed;

  factory AppOrderTimeline.fromMap(Map<String, dynamic> map) {
    return AppOrderTimeline(
      status: map['status'] ?? '',
      time: map['time'] is DateTime 
          ? map['time'] 
          : (map['time'] != null ? (map['time'] as dynamic).toDate() : DateTime.now()),
      completed: map['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'time': time,
      'completed': completed,
    };
  }

  @override
  List<Object?> get props => <Object?>[status, time, completed];
}

class Rider extends Equatable {
  const Rider({
    required this.name,
    required this.phone,
    required this.rating,
  });

  final String name;
  final String phone;
  final double rating;

  factory Rider.fromMap(Map<String, dynamic> map) {
    return Rider(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      rating: (map['rating'] ?? 5.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'rating': rating,
    };
  }

  @override
  List<Object?> get props => <Object?>[name, phone, rating];
}

class AppOrder extends Equatable {
  const AppOrder({
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
    this.userId,
  });

  final String id;
  final String? userId;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final String paymentStatus;
  final List<AppOrderItem> items;
  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double cashbackUsed;
  final double total;
  final DateTime placedAt;
  final Address deliveryAddress;
  final List<AppOrderTimeline> timeline;
  final Rider? rider;

  factory AppOrder.fromMap(Map<String, dynamic> map, [String? docId]) {
    return AppOrder(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'],
      status: OrderStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? ''),
        orElse: () => OrderStatus.placed,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == (map['paymentMethod'] ?? ''),
        orElse: () => PaymentMethod.cod,
      ),
      paymentStatus: map['paymentStatus'] ?? 'Pending',
      items: (map['items'] as List<dynamic>?)
              ?.map((i) => AppOrderItem.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      discount: (map['discount'] ?? 0.0).toDouble(),
      deliveryCharge: (map['deliveryCharge'] ?? 0.0).toDouble(),
      cashbackUsed: (map['cashbackUsed'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      placedAt: map['placedAt'] is DateTime 
          ? map['placedAt'] 
          : (map['placedAt'] != null ? (map['placedAt'] as dynamic).toDate() : DateTime.now()),
      deliveryAddress: Address.fromMap(map['deliveryAddress'] ?? {}),
      timeline: (map['timeline'] as List<dynamic>?)
              ?.map((t) => AppOrderTimeline.fromMap(t as Map<String, dynamic>))
              .toList() ??
          [],
      rider: map['rider'] != null ? Rider.fromMap(map['rider'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'deliveryCharge': deliveryCharge,
      'cashbackUsed': cashbackUsed,
      'total': total,
      'placedAt': placedAt,
      'deliveryAddress': deliveryAddress.toMap(),
      'timeline': timeline.map((t) => t.toMap()).toList(),
      'rider': rider?.toMap(),
    };
  }

  @override
  List<Object?> get props => <Object?>[id, status, total, placedAt, userId];
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

  Color get color {
    switch (this) {
      case OrderStatus.placed:
        return Colors.blue;
      case OrderStatus.confirmed:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.dispatched:
        return Colors.indigo;
      case OrderStatus.outForDelivery:
        return Colors.amber;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
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

class AppNotification extends Equatable {
  const AppNotification({
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

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      time: time,
      type: type,
      read: read ?? this.read,
    );
  }

  factory AppNotification.fromMap(Map<String, dynamic> map, [String? docId]) {
    return AppNotification(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      time: map['time'] is DateTime 
          ? map['time'] 
          : (map['time'] != null ? (map['time'] as dynamic).toDate() : DateTime.now()),
      type: map['type'] ?? 'general',
      read: map['read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'time': time,
      'type': type,
      'read': read,
    };
  }

  @override
  List<Object?> get props => <Object?>[id, title, time, type, read];
}

class AppOffer extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? imageUrl; // Base64 or URL
  final List<Color> colors;
  final int discountPercent;

  const AppOffer({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.colors,
    this.discountPercent = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'colors': colors.map((c) => c.value).toList(),
      'discountPercent': discountPercent,
    };
  }

  factory AppOffer.fromMap(Map<String, dynamic> map, String id) {
    return AppOffer(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      colors: (map['colors'] as List<dynamic>?)
              ?.map((c) => Color(c as int))
              .toList() ??
          const [Colors.blue, Colors.blueAccent],
      discountPercent: map['discountPercent'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, title, description, imageUrl, colors, discountPercent];
}

