import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_dart/bloc/auth_bloc.dart';
import 'package:learn_dart/bloc/auth_bloc_event.dart';

class VerifyEmailView extends StatefulWidget {
  final String title;
  const VerifyEmailView({super.key, required this.title});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  String emailVerifyError = "";

  void setEmailVerifyError(String text) {
    setState(() {
      emailVerifyError = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Center(
          child: Column(
            children: [
              const Text(
                  "We have sent you an email verfication link. Please use that to verify your email."),
              TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthBlocEventUserSendEmail());
                  },
                  child: const Text("Not Received Yet? Resend!")),
              TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthBlocEventUserLogout());
                  },
                  child: const Text("Verified? Login Here..")),
              Text(emailVerifyError),
            ],
          ),
        ));
  }
}
