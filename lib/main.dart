import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_dart/bloc/auth_bloc.dart';
import 'package:learn_dart/bloc/auth_bloc_event.dart';
import 'package:learn_dart/bloc/auth_bloc_state.dart';
import 'package:learn_dart/constants/routes.dart';
import 'package:learn_dart/service/firebase_auth_provider.dart';
import 'package:learn_dart/util/progress_view.dart';
import 'package:learn_dart/views/notes/create_update_notes.dart';
import 'package:learn_dart/views/notes/notes_view.dart';
import 'package:learn_dart/views/login_view.dart';
import 'package:learn_dart/views/password_reset_view.dart';
import 'package:learn_dart/views/register_view.dart';
import 'package:learn_dart/views/verify_email.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomeView(),
      routes: {
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

class MyHomeView extends StatelessWidget {
  const MyHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final authBloc = AuthBloc(FirebaseAuthProvider.instance);
        authBloc.add(AuthBlocEventAuthInitialise());
        return authBloc;
      },
      child: BlocConsumer<AuthBloc, AuthBlocState>(
        listener: (context, state) {
          if (state.isLoading) {
            LoaderView().showLoadingView(
              context: context,
              content: state.loadingContent,
            );
          } else {
            LoaderView().hideLoadingView();
          }
        },
        builder: (context, state) {
          if (state is AuthBlocStateUserLoggedOut) {
            return const LoginView(title: "Login");
          } else if (state is AuthBlocStateUserNeedEmailVerify) {
            return const VerifyEmailView(title: "Verify Email");
          } else if (state is AuthBlocStateUserLoggedIn) {
            return NotesView(
              title: "Notes",
              authUser: state.authUser,
            );
          } else if (state is AuthBlocStateUserRegistring) {
            return const RegisterView(title: "Register");
          } else if (state is AuthBlocStateUserPasswordReset) {
            return const PasswordResetView();
          } else {
            return const NotesLoadingView();
          }
        },
      ),
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
