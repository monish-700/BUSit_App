import 'package:flutter/material.dart';
import '../presentation/settings/settings.dart';
import '../presentation/bus_details/bus_details.dart';
import '../presentation/voice_assistant/voice_assistant.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/live_bus_map/live_bus_map.dart';
import '../presentation/route_search/route_search.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String settings = '/settings';
  static const String busDetails = '/bus-details';
  static const String voiceAssistant = '/voice-assistant';
  static const String login = '/login-screen';
  static const String liveBusMap = '/live-bus-map';
  static const String routeSearch = '/route-search';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    settings: (context) => const Settings(),
    busDetails: (context) => BusDetails(),
    voiceAssistant: (context) => const VoiceAssistant(),
    login: (context) => const LoginScreen(),
    liveBusMap: (context) => const LiveBusMap(),
    routeSearch: (context) => RouteSearch(),
    // TODO: Add your other routes here
  };
}
