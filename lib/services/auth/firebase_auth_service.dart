import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // @override
  // Future<User?> registerWithEmail(String email, String password) async {
  //   final userCredential = await _auth.createUserWithEmailAndPassword(
  //       email: email, password: password);
  //   return userCredential.user;
  // }

  // @override
  // Future<User?> signInWithEmail(String email, String password) async {
  //   final userCredential = await _auth.signInWithEmailAndPassword(
  //       email: email, password: password);
  //   return userCredential.user;
  // }

  // @override
  // Future<User?> signInWithGoogle() async {
    // final googleUser = await GoogleSignIn().signIn();
    // if (googleUser == null) return null;
    // final googleAuth = await googleUser.authentication;
    // final credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth.accessToken,
    //   idToken: googleAuth.idToken,
    // );
    // final userCredential = await _auth.signInWithCredential(credential);
    // return userCredential.user;
  // }

  // @override
  // Future<User?> signInWithApple() async {
  //   final appleCredential = await SignInWithApple.getAppleIDCredential(
  //     scopes: [
  //       AppleIDAuthorizationScopes.email,
  //       AppleIDAuthorizationScopes.fullName
  //     ],
  //   );

  //   final oAuthProvider = OAuthProvider('apple.com');
  //   final credential = oAuthProvider.credential(
  //     idToken: appleCredential.identityToken,
  //     accessToken: appleCredential.authorizationCode,
  //   );

  //   final userCredential = await _auth.signInWithCredential(credential);
  //   return userCredential.user;
  // }

  // @override
  // Future<void> signOut() async {
  //   await _auth.signOut();
  //   // await GoogleSignIn().signOut();
  // }

  // @override
  // User? getCurrentUser() {
  //   return _auth.currentUser;
  // }
}
