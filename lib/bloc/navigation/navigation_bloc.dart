import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState(
    currentTab: NavigationTab.home,
    currentIndex: 0,
  )) {
    on<NavigationTabChanged>(_onNavigationTabChanged);
  }

  void _onNavigationTabChanged(
    NavigationTabChanged event,
    Emitter<NavigationState> emit,
  ) {
    final index = _getIndexFromTab(event.tab);
    emit(state.copyWith(
      currentTab: event.tab,
      currentIndex: index,
    ));
  }

  int _getIndexFromTab(NavigationTab tab) {
    switch (tab) {
      case NavigationTab.home:
        return 0;
      case NavigationTab.discover:
        return 1;
      case NavigationTab.add:
        return 2;
      case NavigationTab.calendar:
        return 3;
      case NavigationTab.profile:
        return 4;
    }
  }

  NavigationTab _getTabFromIndex(int index) {
    switch (index) {
      case 0:
        return NavigationTab.home;
      case 1:
        return NavigationTab.discover;
      case 2:
        return NavigationTab.add;
      case 3:
        return NavigationTab.calendar;
      case 4:
        return NavigationTab.profile;
      default:
        return NavigationTab.home;
    }
  }

  void changeTab(int index) {
    final tab = _getTabFromIndex(index);
    add(NavigationTabChanged(tab));
  }
}