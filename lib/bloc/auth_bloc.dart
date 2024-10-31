import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_dart/bloc/auth_bloc_event.dart';
import 'package:learn_dart/bloc/auth_bloc_state.dart';
import 'package:learn_dart/service/firebase_auth_provider.dart';
import 'package:learn_dart/service/firestore/notes_firestore.dart';

class AuthBloc extends Bloc<AuthBlocEvent, AuthBlocState> {
  AuthBloc(FirebaseAuthProvider provider)
      : super(AuthBlocStateAuthInitialising()) {
    on<AuthBlocEventAuthInitialise>(
      (event, emit) async {
        await Future.sync(() => provider.initialize());
        await Future.delayed(Duration(seconds: 2));
        var user = provider.getCurrentUser();
        if (user == null) {
          emit(AuthBlocStateUserLoggedOut(
            isLoading: false,
          ));
        } else if (!user.emailVerified) {
          provider.sendEmailVerificationLink();
          emit(AuthBlocStateUserNeedEmailVerify());
        } else {
          emit(AuthBlocStateUserLoggedIn(authUser: user));
        }
      },
    );

    on<AuthBlocEventUserLogin>(
      (event, emit) async {
        emit(AuthBlocStateUserLoggedOut(isLoading: true));
        await Future.delayed(Duration(seconds: 1));
        final email = event.email;
        final password = event.password;
        try {
          final user =
              await provider.loginUser(email: email, password: password);
          emit(AuthBlocStateUserLoggedOut(isLoading: false));

          if (!user.emailVerified) {
            emit(AuthBlocStateUserNeedEmailVerify());
          } else {
            emit(AuthBlocStateUserLoggedIn(authUser: user));
          }
        } on Exception catch (e) {
          emit(AuthBlocStateUserLoggedOut(
            isLoading: false,
            exception: e,
          ));
        }
      },
    );

    on<AuthBlocEventUserLogout>(
      (event, emit) async {
        try {
          await provider.signOut();
          emit(AuthBlocStateUserLoggedOut(
            isLoading: false,
          ));
        } on Exception catch (e) {
          emit(AuthBlocStateUserLoggedOut(
            isLoading: false,
            exception: e,
          ));
        }
      },
    );

    on<AuthBlocEventUserSendEmail>(
      (event, emit) async {
        try {
          provider.sendEmailVerificationLink();
          emit(AuthBlocStateUserNeedEmailVerify());
        } on Exception catch (e) {
          emit(AuthBlocStateUserLoggedOut(
            isLoading: false,
            exception: e,
          ));
        }
      },
    );

    on<AuthBlocEventUserRegister>(
      (event, emit) async {
        final email = event.email;
        final password = event.password;
        try {
          emit(AuthBlocStateUserRegistring(
            isLoading: true,
          ));
          await Future.delayed(Duration(seconds: 1));

          await provider.registerUser(email: email, password: password);
          provider.sendEmailVerificationLink();
          emit(AuthBlocStateUserRegistring(
            isLoading: false,
          ));
          emit(AuthBlocStateUserNeedEmailVerify());
        } on Exception catch (e) {
          emit(AuthBlocStateUserRegistring(
            isLoading: false,
            exception: e,
          ));
        }
      },
    );

    on<AuthBlocEventUserDelete>((event, emit) async {
      CloudStoreService().deleteNotesForUser(provider.getCurrentUser()!);
      await provider.deleteCurUser();
      emit(AuthBlocStateUserLoggedOut(
        isLoading: false,
      ));
    });

    on<AuthBlocEventUserRegistering>((event, emit) async {
      emit(AuthBlocStateUserRegistring(isLoading: false));
    });
  }
}
