import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

extension IterableExtensions<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E element) f) {
    var i = 0;
    return map((e) => f(i++, e));
  }
}

extension BuildContextExtensions on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  ThemeData get theme => Theme.of(this);

  bool get isDarkMode => theme.brightness == Brightness.dark;

  NavigatorState get navigator => Navigator.of(this);
}

extension GoRouterExt on GoRouter {
  String get _currentRoute => routerDelegate.currentConfiguration.matches.last.matchedLocation;

  /// Pop until the route with the given [path] is reached.
  /// Example
  /// ``` dart
  ///  GoRouter.of(context).popUntil(SettingsScreen.route);
  /// ```

  void popUntil(String path) {
    var currentRoute = _currentRoute;
    while (currentRoute != path && canPop()) {
      pop();
      currentRoute = _currentRoute;
    }
  }
}

extension IntExtensions on int? {
  String toCurrencyString({String currencySymbol = '₫'}) {
    return '$currencySymbol${((this ?? 0 )/ 1000000).toStringAsFixed(2)}M';
  }

  String toDateString() {
    final date = DateTime.fromMillisecondsSinceEpoch(this ?? 0);
    return '${date.day}/${date.month}/${date.year}';
  }

  String currencyFormat() {
    return (this ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}

extension StringExtensions on String? {
  bool get isNotEmpty => this?.isNotEmpty ?? false;
  bool get isEmpty => this?.isEmpty ?? true;

  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

abstract class GlobalExtensions {
  static void tryCatch(Function() callback, {Function(Object)? onError}) {
    try {
      callback();
    } catch (e) {
      onError?.call(e);
    }
  }

  static void runEmitterBlocSafe<T>(Emitter<T> emit, Function(Emitter<T>) callback) {
    if (!emit.isDone) callback(emit);
  }

  static String generateRandomKey({
    int length = 16,
    bool includeLetters = true,
    bool includeNumbers = true,
    bool includeSpecialChars = false,
  }) {
    final random = Random();
    final letterLowercase = 'abcdefghijklmnopqrstuvwxyz';
    final letterUppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final numbers = '0123456789';
    final special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (includeLetters) chars += letterLowercase + letterUppercase;
    if (includeNumbers) chars += numbers;
    if (includeSpecialChars) chars += special;

    if (chars.isEmpty) chars = letterLowercase + numbers; // Fallback if nothing selected

    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
