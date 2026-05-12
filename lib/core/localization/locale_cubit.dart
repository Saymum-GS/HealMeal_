import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en'));

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'en';
    emit(Locale(langCode));
  }

  Future<void> setEnglish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', 'en');
    emit(const Locale('en'));
  }

  Future<void> setBangla() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', 'bn');
    emit(const Locale('bn'));
  }
}

