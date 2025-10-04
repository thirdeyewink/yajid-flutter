import 'package:equatable/equatable.dart';

enum NavigationTab { home, discover, add, calendar, profile }

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class NavigationTabChanged extends NavigationEvent {
  final NavigationTab tab;

  const NavigationTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

class NavigationPushScreen extends NavigationEvent {
  final String routeName;
  final Map<String, dynamic>? arguments;

  const NavigationPushScreen(this.routeName, {this.arguments});

  @override
  List<Object?> get props => [routeName, arguments];
}

class NavigationPopScreen extends NavigationEvent {
  const NavigationPopScreen();
}