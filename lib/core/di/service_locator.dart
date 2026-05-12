import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/product_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/offer_repository.dart';
import '../repositories/suggestion_repository.dart';
import '../repositories/lab_repository.dart';
import '../repositories/lab_test_repository.dart';
import '../repositories/prescription_repository.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);

  // Repositories
  getIt.registerLazySingleton(() => ProductRepository());
  getIt.registerLazySingleton(() => OrderRepository());
  getIt.registerLazySingleton(() => UserRepository());
  getIt.registerLazySingleton(() => OfferRepository());
  getIt.registerLazySingleton(() => SuggestionRepository());
  getIt.registerLazySingleton(() => LabRepository());
  getIt.registerLazySingleton(() => LabTestRepository());
  getIt.registerLazySingleton(() => PrescriptionRepository());
}
