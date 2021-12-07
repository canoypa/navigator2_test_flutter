import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

class AppPathState extends StateNotifier<Uri> {
  AppPathState() : super(Uri.parse("/"));

  void route(Uri uri) {
    state = uri;
  }

  Uri get current {
    return state;
  }
}

final appPathProvider =
    StateNotifierProvider<AppPathState, Uri>((_) => AppPathState());

class HomeRouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Uri _routeConfiguration = Uri.parse("/");

  @override
  Uri get currentConfiguration => _routeConfiguration;

  @override
  Widget build(BuildContext context) {
    return ProviderListener(
      provider: appPathProvider,
      onChange: (context, Uri configuration) {
        _routeConfiguration = configuration;
        notifyListeners();
      },
      child: Navigator(
        key: navigatorKey,
        pages: [
          HomePage(
            key: const ValueKey("/"),
            child: Scaffold(
              appBar: AppBar(title: const Text("Home Page")),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Current Path: ${_routeConfiguration.path}"),
                    OutlinedButton(
                      child: const Text("Go to /test"),
                      onPressed: () {
                        context
                            .read(appPathProvider.notifier)
                            .route(Uri.parse("/test"));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_routeConfiguration.pathSegments.isNotEmpty &&
              _routeConfiguration.pathSegments[0] == "test")
            HomePage(
              key: const ValueKey("/test"),
              child: TestScreen(back: () {
                context.read(appPathProvider.notifier).route(Uri.parse("/"));
              }),
            ),
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;

          context.read(appPathProvider.notifier).route(Uri.parse("/"));

          return true;
        },
      ),
    );
  }

  @override
  Future<void> setNewRoutePath(Uri configuration) async {
    _routeConfiguration = configuration;
  }
}

class TestScreen extends ConsumerWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final VoidCallback back;

  TestScreen({Key? key, required this.back}) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _route = watch(appPathProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Test Page")),
      body: Navigator(
        key: navigatorKey,
        pages: [
          TestPage(
            key: const ValueKey("/test/home"),
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Current Path: ${_route.path}"),
                    OutlinedButton(
                      child: const Text("Go to /"),
                      onPressed: back,
                    ),
                    OutlinedButton(
                      child: const Text("Go to /test/test"),
                      onPressed: () {
                        context
                            .read(appPathProvider.notifier)
                            .route(Uri.parse("/test/test"));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_route.path == "/test/test")
            TestPage(
              key: const ValueKey("/test/test"),
              child: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Current Path: ${_route.path}"),
                      OutlinedButton(
                        child: const Text("Go to /"),
                        onPressed: back,
                      ),
                      OutlinedButton(
                        child: const Text("Go to /test"),
                        onPressed: () {
                          context
                              .read(appPathProvider.notifier)
                              .route(Uri.parse("/test"));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;

          context.read(appPathProvider.notifier).route(Uri.parse("/test"));

          return true;
        },
      ),
    );
  }
}

class TestRouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final VoidCallback back;

  TestRouterDelegate({required this.back});

  Uri _routeConfiguration = Uri.parse("/test");

  @override
  Uri get currentConfiguration => _routeConfiguration;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        TestPage(
          key: const ValueKey("/test/home"),
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Current Path: ${_routeConfiguration.path}"),
                  OutlinedButton(
                    child: const Text("Go to /"),
                    onPressed: back,
                  ),
                  OutlinedButton(
                    child: const Text("Go to /test/test"),
                    onPressed: () => _route(Uri.parse("/test/test")),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_routeConfiguration.path == "/test/test")
          TestPage(
            key: const ValueKey("/test/test"),
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Current Path: ${_routeConfiguration.path}"),
                    OutlinedButton(
                      child: const Text("Go to /"),
                      onPressed: back,
                    ),
                    OutlinedButton(
                      child: const Text("Go to /test"),
                      onPressed: () => _route(Uri.parse("/test")),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;

        _routeConfiguration = Uri.parse("/test");

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
