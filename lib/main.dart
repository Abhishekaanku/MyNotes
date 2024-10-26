import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_dart/constants/routes.dart';
import 'package:learn_dart/service/firebase_auth_provider.dart';
import 'package:learn_dart/views/notes/create_update_notes.dart';
import 'package:learn_dart/views/notes/notes_view.dart';
import 'package:learn_dart/views/login_view.dart';
import 'package:learn_dart/views/register_view.dart';
import 'package:learn_dart/views/verify_email.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

Future<void> future() async {
  await Future.delayed(const Duration(seconds: 2), () => {});
  await Future.sync(() => FirebaseAuthProvider.instance.initialize());

  var user = FirebaseAuthProvider.instance.getCurrentUser();
  if (user != null && !user.emailVerified) {
    await FirebaseAuthProvider.instance.sendEmailVerificationLink();
  }
  return;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              late final Widget homeWidget;
              if (1 == 1) {
                return AppWidget(
                    homeWidget: HomeView(
                  title: "Testing",
                ));
              }
              var user = FirebaseAuthProvider.instance.getCurrentUser();
              if (user == null) {
                homeWidget = const LoginView(title: "Login");
              } else if (!user.emailVerified) {
                homeWidget = const VerifyEmailView(title: "Verify Email");
              } else {
                homeWidget = const NotesView(title: "Notes");
              }
              return AppWidget(homeWidget: homeWidget);
            default:
              return const AppWidget(homeWidget: NotesLoadingView());
          }
        });
  }
}

class AppWidget extends StatelessWidget {
  final Widget homeWidget;
  const AppWidget({
    super.key,
    required this.homeWidget,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: homeWidget,
      routes: {
        notesRoute: (context) => const NotesView(title: "Notes"),
        loginRoute: (context) => const LoginView(title: "Login"),
        registerRoute: (context) => const RegisterView(title: "Register"),
        verifyEmailRoute: (context) =>
            const VerifyEmailView(title: "Verify Email"),
        addNotesRoute: (context) => const AddNotesView(
              title: "Add Notes",
            ),
      },
    );
  }
}

class HomeView extends StatefulWidget {
  final String title;
  const HomeView({super.key, required this.title});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(widget.title),
        ),
        body: BlocConsumer<CounterBloc, CounterState>(
          builder: (context, state) {
            final invalidVal =
                state is CounterStateInvalid ? state.invalidVal : "";
            return Column(
              children: [
                Text("Your current state is ${state.value}"),
                Visibility(
                  visible: state is CounterStateInvalid,
                  child: Text("Invalid Value => $invalidVal"),
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Please input value"),
                  controller: _controller,
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        BlocProvider.of<CounterBloc>(context).add(
                            CounterEventIncrement(value: _controller.text));
                      },
                      child: Text("Plus"),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(
                            CounterEventDecrement(value: _controller.text));
                      },
                      child: Text("Minus"),
                    ),
                  ],
                ),
              ],
            );
          },
          listener: (context, state) => _controller.clear(),
        ),
      ),
    );
  }
}

abstract class CounterEvent {
  final String value;

  CounterEvent({required this.value});
}

class CounterEventIncrement extends CounterEvent {
  CounterEventIncrement({required super.value});
}

class CounterEventDecrement extends CounterEvent {
  CounterEventDecrement({required super.value});
}

abstract class CounterState {
  final int value;

  CounterState({required this.value});
}

class CounterStateValid extends CounterState {
  CounterStateValid({required super.value});
}

class CounterStateInvalid extends CounterState {
  final String invalidVal;
  CounterStateInvalid({required int previous, required this.invalidVal})
      : super(value: previous);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterStateValid(value: 0)) {
    on<CounterEventIncrement>(
      (event, emit) {
        String val = event.value;
        int? x = int.tryParse(val);
        if (x != null) {
          emit.call(CounterStateValid(value: state.value + x));
        } else {
          emit.call(
              CounterStateInvalid(previous: state.value, invalidVal: val));
        }
      },
    );

    on<CounterEventDecrement>(
      (event, emit) {
        String val = event.value;
        int? parsedValue = int.tryParse(val);
        if (parsedValue != null) {
          emit.call(CounterStateValid(value: state.value - parsedValue));
        } else {
          emit.call(
              CounterStateInvalid(previous: state.value, invalidVal: val));
        }
      },
    );
  }
}
