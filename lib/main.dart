import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:navigator2_test_flutter/router.dart';

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

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      routeInformationParser: HomeRouteInformationParser(),
      routerDelegate: HomeRouterDelegate(
        getCurrent: () => context.read(appPathProvider.notifier).current,
        onNewRoute: context.read(appPathProvider.notifier).route,
      ),
    );
  }
}
