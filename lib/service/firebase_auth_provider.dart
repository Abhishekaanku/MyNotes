import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:learn_dart/exception/auth_exceptions.dart';
import 'package:learn_dart/firebase_options.dart';
import 'package:learn_dart/service/auth_service.dart';

class FirebaseAuthProvider implements NotesAuthProvider {
  static FirebaseAuthProvider? _singletonInstance;

  static FirebaseAuthProvider get instance {
    if (_singletonInstance == null) {
      _singletonInstance = FirebaseAuthProvider();
    }
    return _singletonInstance!;
  }

  @override
  void initialize() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  @override
  Future<AuthUser> registerUser(
      {required String email, required String password}) async {
    try {
      var userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user == null) {
        throw UserNotLoggedInException();
      }
      return AuthUser.firebase(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw GenericAuthException(code: e.code);
    } on UserNotLoggedInException {
      rethrow;
    } catch (e) {
      throw GenericAuthException(code: "technical_error");
    }
  }

  @override
  Future<AuthUser> loginUser(
      {required String email, required String password}) async {
    try {
      var userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user == null) {
        throw UserNotLoggedInException();
      }
      return AuthUser.firebase(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw GenericAuthException(code: e.code);
    } on UserNotLoggedInException {
      rethrow;
    } catch (e) {
      throw GenericAuthException(code: "technical_error");
    }
  }

  @override
  Future<void> sendEmailVerificationLink() {
    try {
      var userCredential = FirebaseAuth.instance.currentUser;
      if (userCredential == null) {
        throw UserNotLoggedInException();
      }
      return userCredential.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw GenericAuthException(code: e.code);
    } on UserNotLoggedInException {
      rethrow;
    } catch (e) {
      throw GenericAuthException(code: "technical_error");
    }
  }

  @override
  Future<void> signOut() {
    try {
      return FirebaseAuth.instance.signOut();
    } catch (e) {
      throw GenericAuthException(code: "technical_error");
    }
  }

  @override
  AuthUser? getCurrentUser() {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    return AuthUser.firebase(user);
  }

  @override
  Future<void> deleteCurUser() {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw UserNotLoggedInException();
    }
    return user.delete();
  }

  @override
  Future<void> sendPasswordResetLink(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw GenericAuthException(code: e.code);
    } catch (e) {
      throw GenericAuthException(code: "Unknown Error");
    }
  }
}
