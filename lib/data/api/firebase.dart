import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:six_cash/data/model/abank.dart';

class ApiFirebase extends GetxController implements GetxService {
  Future<bool> addNewBankAccount(ABank bank, String idUser) async {
    final response = await FirebaseFirestore.instance
        .collection("banks")
        .withConverter(
          fromFirestore: (snapshot, options) =>
              ABank.fromFirestore(snapshot, options),
          toFirestore: (ABank value, options) => value.toFirestore(),
        )
        .doc(idUser)
        .set(bank)
        .then((value) => true)
        .catchError((onError) => false);
    return response;
  }

  Future<bool> updateBankAccount(ABank bank, String idUser) async {
    final response = await FirebaseFirestore.instance
        .collection("banks")
        .withConverter(
          fromFirestore: (snapshot, options) =>
              ABank.fromFirestore(snapshot, options),
          toFirestore: (ABank value, options) => value.toFirestore(),
        )
        .doc(idUser)
        .update(bank.toFirestore())
        .then((value) => true)
        .catchError((onError) => false);
    return response;
  }

  Future<bool> checkBankAccount(String userId) async {
    final response = await FirebaseFirestore.instance
        .collection("banks")
        .withConverter(
          fromFirestore: (snapshot, options) =>
              ABank.fromFirestore(snapshot, options),
          toFirestore: (ABank value, options) => value.toFirestore(),
        )
        .doc(userId)
        .get();
    return response.exists;
  }

  Future<ABank> getBank(String uid) async {
    final response = await FirebaseFirestore.instance
        .collection("banks")
        .withConverter(
          fromFirestore: (snapshot, options) =>
              ABank.fromFirestore(snapshot, options),
          toFirestore: (ABank value, options) => value.toFirestore(),
        )
        .doc(uid)
        .get();
    return response.data();
  }
}
