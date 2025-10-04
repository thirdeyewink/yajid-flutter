import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yajid/bloc/navigation/navigation_bloc.dart';
import 'package:yajid/bloc/navigation/navigation_event.dart';
import 'package:yajid/bloc/navigation/navigation_state.dart';

void main() {
  group('NavigationBloc', () {
    late NavigationBloc navigationBloc;

    setUp(() {
      navigationBloc = NavigationBloc();
    });

    tearDown(() {
      navigationBloc.close();
    });

    test('initial state has home tab selected with index 0', () {
      expect(
        navigationBloc.state,
        equals(const NavigationState(
          currentTab: NavigationTab.home,
          currentIndex: 0,
        )),
      );
    });

    group('NavigationTabChanged', () {
      blocTest<NavigationBloc, NavigationState>(
        'emits correct state when home tab is selected',
        build: () => navigationBloc,
        act: (bloc) => bloc.add(const NavigationTabChanged(NavigationTab.home)),
        expect: () => [
          const NavigationState(
            currentTab: NavigationTab.home,
            currentIndex: 0,
          ),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'emits correct state when discover tab is selected',
        build: () => navigationBloc,
        act: (bloc) => bloc.add(const NavigationTabChanged(NavigationTab.discover)),
        expect: () => [
          const NavigationState(
            currentTab: NavigationTab.discover,
            currentIndex: 1,
          ),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'emits correct state when add tab is selected',
        build: () => navigationBloc,
        act: (bloc) => bloc.add(const NavigationTabChanged(NavigationTab.add)),
        expect: () => [
          const NavigationState(
            currentTab: NavigationTab.add,
            currentIndex: 2,
          ),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'emits correct state when calendar tab is selected',
        build: () => navigationBloc,
        act: (bloc) => bloc.add(const NavigationTabChanged(NavigationTab.calendar)),
        expect: () => [
          const NavigationState(
            currentTab: NavigationTab.calendar,
            currentIndex: 3,
          ),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'emits correct state when profile tab is selected',
        build: () => navigationBloc,
        act: (bloc) => bloc.add(const NavigationTabChanged(NavigationTab.profile)),
        expect: () => [
          const NavigationState(
            currentTab: NavigationTab.profile,
            currentIndex: 4,
          ),
        ],
      );
    });

    group('changeTab method', () {
      blocTest<NavigationBloc, NavigationState>(
        'changes to home tab when index 0 is passed',
        build: () => navigationBloc,
        act: (bloc) => bloc.changeTab(0),
        expect: () => [
          const NavigationState(
            currentTab: NavigationTab.home,
            currentIndex: 0,
          ),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'changes to discover tab when index 1 is passed',
        build: () => navigationBloc,
        act: (bloc) => bloc.changeTab(1),
        expect: () => [
          const NavigationState(
            currentTab: NavigationTab.discover,
            currentIndex: 1,
          ),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'changes to add tab when index 2 is passed',
        build: () => navigationBloc,
        act: (bloc) => bloc.changeTab(2),
        expect: () => [
          const NavigationState(
            currentTab: NavigationTab.add,
            currentIndex: 2,
          ),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'changes to calendar tab when index 3 is passed',
        build: () => navigationBloc,
        act: (bloc) => bloc.changeTab(3),
        expect: () => [
          const NavigationState(
            currentTab: NavigationTab.calendar,
            currentIndex: 3,
          ),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'changes to profile tab when index 4 is passed',
        build: () => navigationBloc,
        act: (bloc) => bloc.changeTab(4),
        expect: () => [
          const NavigationState(
            currentTab: NavigationTab.profile,
            currentIndex: 4,
          ),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'defaults to home tab when invalid index is passed',
        build: () => navigationBloc,
        act: (bloc) => bloc.changeTab(99),
        expect: () => [
          const NavigationState(
            currentTab: NavigationTab.home,
            currentIndex: 0,
          ),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'defaults to home tab when negative index is passed',
        build: () => navigationBloc,
        act: (bloc) => bloc.changeTab(-1),
        expect: () => [
          const NavigationState(
            currentTab: NavigationTab.home,
            currentIndex: 0,
          ),
        ],
      );
    });

    group('Tab transitions', () {
      blocTest<NavigationBloc, NavigationState>(
        'transitions correctly through multiple tabs',
        build: () => navigationBloc,
        act: (bloc) {
          bloc.add(const NavigationTabChanged(NavigationTab.discover));
          bloc.add(const NavigationTabChanged(NavigationTab.profile));
          bloc.add(const NavigationTabChanged(NavigationTab.home));
        },
        expect: () => [
          const NavigationState(
            currentTab: NavigationTab.discover,
            currentIndex: 1,
          ),
          const NavigationState(
            currentTab: NavigationTab.profile,
            currentIndex: 4,
          ),
          const NavigationState(
            currentTab: NavigationTab.home,
            currentIndex: 0,
          ),
        ],
      );
    });
  });
}