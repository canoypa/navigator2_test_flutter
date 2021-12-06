import 'package:flutter/material.dart';
import 'package:navigator2_test_flutter/test_page.dart';

class HomeRouteInformationParser extends RouteInformationParser<Uri> {
  @override
  Future<Uri> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? "/");
    return uri;
  }

  @override
  RouteInformation restoreRouteInformation(Uri configuration) {
    return RouteInformation(location: configuration.path);
  }
}

class HomeRouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Uri _routeConfiguration = Uri.parse("/");

  @override
  Uri get currentConfiguration {
    return _routeConfiguration;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        TestPage(
          key: const ValueKey("/"),
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Current Path: ${_routeConfiguration.path}"),
                  OutlinedButton(
                    child: const Text("Go to /test"),
                    onPressed: () => _route(Uri.parse("/test")),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_routeConfiguration.path == "/test")
          TestPage(
            key: const ValueKey("/test"),
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Current Path: ${_routeConfiguration.path}"),
                    OutlinedButton(
                      child: const Text("Go to /"),
                      onPressed: () => _route(Uri.parse("/")),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;

        _routeConfiguration = Uri.parse("/");

        notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(Uri configuration) async {
    _routeConfiguration = configuration;
  }

  _route(Uri configuration) {
    _routeConfiguration = configuration;
    notifyListeners();
  }
}
