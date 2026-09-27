import 'package:flutter_bloc/flutter_bloc.dart';

class MainNavigationCubit extends Cubit<int> {
  MainNavigationCubit({int initialIndex = 2})
    : super(initialIndex);

  void selectTab(int index) {
    if (index == state) return;

    emit(index);
  }

  void openChat() {
    selectTab(0);
  }

  void openSavedJobs() {
    selectTab(1);
  }

  void openHome() {
    selectTab(2);
  }

  void openRoadmap() {
    selectTab(3);
  }

  void openProfile() {
    selectTab(4);
  }
}
