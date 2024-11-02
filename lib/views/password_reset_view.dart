import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_dart/bloc/auth_bloc.dart';
import 'package:learn_dart/bloc/auth_bloc_event.dart';
import 'package:learn_dart/bloc/auth_bloc_state.dart';
import 'package:learn_dart/exception/auth_exceptions.dart';
import 'package:learn_dart/util/alert_dialog.dart';

class PasswordResetView extends StatefulWidget {
  const PasswordResetView({super.key});

  @override
  State<PasswordResetView> createState() => _PasswordResetViewState();
}

class _PasswordResetViewState extends State<PasswordResetView> {
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
    return BlocListener<AuthBloc, AuthBlocState>(
      listener: (context, state) async {
        if (state is AuthBlocStateUserPasswordReset) {
          if (state.isSuccess) {
            await showSingleActionDialog(
              context: context,
              title: "Success",
              content: "We have emailed you a password reset link.",
            );
          } else if (state.exception != null) {
            await showSingleActionDialog(
              context: context,
              title: "Error Occurred",
              content: (state.exception as GenericAuthException).code,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Password Reset"),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Enter Your Email",
                ),
                autofocus: true,
                controller: _controller,
                enableSuggestions: false,
              ),
              TextButton(
                  onPressed: () {
                    final email = _controller.text;
                    _controller.clear();
                    context
                        .read<AuthBloc>()
                        .add(AuthBlocEventSendPasswordReset(email: email));
                  },
                  child: Text("Send Reset Link")),
              TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthBlocEventUserLogout());
                  },
                  child: Text("Go to Login")),
            ],
          ),
        ),
      ),
    );
  }
}
