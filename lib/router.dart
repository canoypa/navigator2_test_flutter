import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:navigator2_test_flutter/main.dart';
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

  final Uri Function() getCurrent;
  final void Function(Uri) onNewRoute;

  HomeRouterDelegate({
    required this.getCurrent,
    required this.onNewRoute,
  });

  @override
  Uri get currentConfiguration {
    return getCurrent();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderListener(
      provider: appPathProvider,
      onChange: (context, Uri configuration) {
        print("change: $configuration");
        notifyListeners();
      },
      child: Consumer(
        builder: (context, watch, child) {
          final _route = watch(appPathProvider);

          return Navigator(
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
                        Text("Current Path: ${_route.path}"),
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
              if (_route.pathSegments.isNotEmpty &&
                  _route.pathSegments[0] == "test")
                HomePage(
                  key: const ValueKey("/test"),
                  child: TestScreen(back: () {
                    context
                        .read(appPathProvider.notifier)
                        .route(Uri.parse("/"));
                  }),
                ),
            ],
            onPopPage: (route, result) {
              if (!route.didPop(result)) return false;

              context.read(appPathProvider.notifier).route(Uri.parse("/"));

              return true;
            },
          );
        },
      ),
    );
  }

  @override
  Future<void> setNewRoutePath(Uri configuration) async {
    onNewRoute(configuration);
  }
}

class TestScreen extends ConsumerWidget {
  final VoidCallback back;

  const TestScreen({Key? key, required this.back}) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _route = watch(appPathProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Test Page")),
      body: Navigator(
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
