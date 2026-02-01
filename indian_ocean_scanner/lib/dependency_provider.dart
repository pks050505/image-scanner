import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/scan/data/repositories/scan_repository.dart';
import 'features/scan/presentation/bloc/scan_bloc.dart';

class DependencyProvider extends StatelessWidget {
  const DependencyProvider({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ScanBloc>(
          create: (context) => ScanBloc(
            repository: ScanRepository(), // dependency inject
          ),
          lazy: false,
        ),
        // Example future bloc: BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
      ],
      child: child,
    );
  }
}
