import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_dart/bloc/auth_bloc.dart';
import 'package:learn_dart/bloc/auth_bloc_event.dart';
import 'package:learn_dart/bloc/auth_bloc_state.dart';
import 'package:learn_dart/exception/auth_exceptions.dart';
import 'package:learn_dart/util/alert_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key, required this.title});
  final String title;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthBlocState>(
      listener: (context, state) async {
        if (state is AuthBlocStateUserRegistring) {
          if (state.exception != null) {
            late final String errorMsg;
            if (state.exception is GenericAuthException) {
              errorMsg = (state.exception as GenericAuthException).code;
            } else if (state.exception is UserNotLoggedInException) {
              errorMsg = (state.exception as GenericAuthException).code;
            } else {
              errorMsg = state.exception.toString();
            }
            await showSingleActionDialog(
              context: context,
              title: "Register Error",
              content: errorMsg,
            );
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
          ),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(hintText: "Enter Email"),
                    keyboardType: TextInputType.emailAddress,
                    controller: _email,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofocus: true,
                  ),
                  TextField(
                    decoration:
                        const InputDecoration(hintText: "Enter Password"),
                    controller: _password,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                  TextButton(
                      onPressed: () async {
                        final email = _email.text;
                        final pass = _password.text;
                        context.read<AuthBloc>().add(AuthBlocEventUserRegister(
                              email: email,
                              password: pass,
                            ));
                      },
                      child: const Text("Register")),
                  TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthBlocEventUserLogout());
                      },
                      child: const Text("Already Registered? Login Here!"))
                ],
              ),
            ),
          )),
    );
  }
}
