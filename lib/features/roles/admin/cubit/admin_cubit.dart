import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/models.dart';
import '../../../../core/repositories/order_repository.dart';
import '../../../../core/repositories/user_repository.dart';
import '../../../../core/repositories/offer_repository.dart';
import '../../../../core/repositories/suggestion_repository.dart';
import '../../../../core/repositories/lab_repository.dart';
import 'package:flutter/foundation.dart';

class AdminState {
  final List<AppOrder> allOrders;
  final List<AppUser> allUsers;
  final List<AppOffer> currentOffers;
  final List<ProductSuggestion> suggestions;
  final List<LabBooking> labBookings;
  final bool isLoading;
  final String? error;

  const AdminState({
    this.allOrders = const [],
    this.allUsers = const [],
    this.currentOffers = const [],
    this.suggestions = const [],
    this.labBookings = const [],
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    List<AppOrder>? allOrders,
    List<AppUser>? allUsers,
    List<AppOffer>? currentOffers,
    List<ProductSuggestion>? suggestions,
    List<LabBooking>? labBookings,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      allOrders: allOrders ?? this.allOrders,
      allUsers: allUsers ?? this.allUsers,
      currentOffers: currentOffers ?? this.currentOffers,
      suggestions: suggestions ?? this.suggestions,
      labBookings: labBookings ?? this.labBookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminCubit extends Cubit<AdminState> {
  final OrderRepository _orderRepository;
  final UserRepository _userRepository;
  final OfferRepository _offerRepository;
  final SuggestionRepository _suggestionRepository;
  final LabRepository _labRepository;
  
  StreamSubscription<List<AppOrder>>? _orderSubscription;
  StreamSubscription<List<AppUser>>? _userSubscription;
  StreamSubscription<List<AppOffer>>? _offerSubscription;
  StreamSubscription<List<ProductSuggestion>>? _suggestionSubscription;
  StreamSubscription<List<LabBooking>>? _labSubscription;

  AdminCubit({
    required OrderRepository orderRepository,
    required UserRepository userRepository,
    required OfferRepository offerRepository,
    required SuggestionRepository suggestionRepository,
    required LabRepository labRepository,
  })  : _orderRepository = orderRepository,
        _userRepository = userRepository,
        _offerRepository = offerRepository,
        _suggestionRepository = suggestionRepository,
        _labRepository = labRepository,
        super(const AdminState()) {
    _initStreams();
  }

  void _initStreams() {
    emit(state.copyWith(isLoading: true));
    
    _orderSubscription = _orderRepository.watchOrders().listen(
      (orders) {
        emit(state.copyWith(allOrders: orders, isLoading: false));
      },
      onError: (e) => emit(state.copyWith(isLoading: false, error: e.toString())),
    );

    _userSubscription = _userRepository.watchUsers().listen(
      (users) {
        emit(state.copyWith(allUsers: users));
      },
      onError: (e) => debugPrint("Error watching users: $e"),
    );

    _offerSubscription = _offerRepository.watchOffers().listen(
      (offers) {
        emit(state.copyWith(currentOffers: offers));
      },
      onError: (e) => debugPrint("Error watching offers: $e"),
    );

    _suggestionSubscription = _suggestionRepository.watchSuggestions().listen(
      (suggestions) {
        emit(state.copyWith(suggestions: suggestions));
      },
      onError: (e) => debugPrint("Error watching suggestions: $e"),
    );

    _labSubscription = _labRepository.watchBookings().listen(
      (bookings) {
        emit(state.copyWith(labBookings: bookings));
      },
      onError: (e) => debugPrint("Error watching lab bookings: $e"),
    );
  }

  Future<void> updateRole(String userId, String role) async {
    try {
      await _userRepository.updateUserRole(userId, role);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }


  Future<void> deleteOffer(String id) async {
    try {
      await _offerRepository.deleteOffer(id);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> assignRider(String orderId, AppUser riderUser) async {
    try {
      await _orderRepository.assignRider(orderId, riderUser);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    _userSubscription?.cancel();
    _offerSubscription?.cancel();
    _suggestionSubscription?.cancel();
    _labSubscription?.cancel();
    return super.close();
  }
}

