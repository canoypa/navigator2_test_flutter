import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      routeInformationParser: HomeRouteInformationParser(),
      routerDelegate: HomeRouterDelegate(
        getCurrent: () => ref.read(appPathProvider.notifier).current,
        onNewRoute: ref.read(appPathProvider.notifier).route,
      ),
    );
  }
}
