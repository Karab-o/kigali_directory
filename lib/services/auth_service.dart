import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  
  Future<String?> signUp(String email, String password, String name) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user!.sendEmailVerification();
      await cred.user!.updateDisplayName(name.trim());
     
      final user = UserModel(
        uid: cred.user!.uid,
        email: email.trim(),
        displayName: name.trim(),
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(cred.user!.uid).set(user.toMap());
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e.code, e.message);
    } on FirebaseException catch (e) {
      
      return 'Firebase error: ${e.message ?? e.code}. Check Firestore rules.';
    } catch (e) {
      
      final msg = e.toString();
      if (msg.contains('SocketException') || msg.contains('network')) {
        return 'No internet connection. Check your network and try again.';
      }
      return 'Error: ${msg.length > 80 ? "${msg.substring(0, 80)}..." : msg}';
    }
  }

  
  Future<String?> logIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e.code, e.message);
    } on FirebaseException catch (e) {
      return 'Firebase error: ${e.message ?? e.code}.';
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('SocketException') || msg.contains('network')) {
        return 'No internet connection. Check your network and try again.';
      }
      return 'Error: ${msg.length > 80 ? "${msg.substring(0, 80)}..." : msg}';
    }
  }

  Future<void> logOut() => _auth.signOut();

  
  Future<void> reloadUser() async => _auth.currentUser?.reload();

  
  Future<String?> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) return 'No user signed in.';
    if (user.emailVerified) return null;
    try {
      await user.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e.code, e.message);
    } catch (e) {
      return e.toString();
    }
  }

  
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  String _friendlyAuthError(String code, String? rawMessage) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Enable it in Firebase Console → Authentication → Sign-in method.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection and try again.';
      case 'invalid-api-key':
      case 'api-key-not-valid':
        return 'Invalid Firebase configuration. Re-download google-services.json and firebase_options.';
      case 'permission-denied':
        return 'Permission denied. Check Firestore security rules for the users collection.';
      default:
        return rawMessage != null && rawMessage.isNotEmpty
            ? rawMessage
            : 'Authentication error ($code). Please try again.';
    }
  }
}
