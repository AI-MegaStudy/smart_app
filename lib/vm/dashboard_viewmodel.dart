import 'package:flutter/material.dart';
import 'package:smart_app/model/dashboard_model.dart';
import 'package:smart_app/repositories/dashboard_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository repository;

  DashboardViewModel(this.repository);

  bool isLoading = false;
  String? errorMessage;
  DashboardModel? dashboard;

  Future<void> loadDashboard() async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      dashboard = await repository.fetchDashboard();
    } catch (error) {
      errorMessage = error.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
