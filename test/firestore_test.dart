import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
  MockSpec<CollectionReference>(),
  MockSpec<DocumentReference>(),
  MockSpec<Query>(),
  MockSpec<QuerySnapshot>(),
  MockSpec<QueryDocumentSnapshot>(),
  MockSpec<DocumentSnapshot>(),
  MockSpec<Transaction>(),

  MockSpec<auth.User>(),
  MockSpec<auth.FirebaseAuth>(),
  MockSpec<auth.UserCredential>(),
])
void main() {
  // Method to set up the test environment
  // Run: flutter pub run build_runner build --delete-conflicting-outputs
}
