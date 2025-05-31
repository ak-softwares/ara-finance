import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../features/personalization/models/user_model.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/helpers/encryption_hepler.dart';
import '../../../database/mongodb/mongo_delete.dart';
import '../../../database/mongodb/mongo_fetch.dart';
import '../../../database/mongodb/mongo_insert.dart';
import '../../../database/mongodb/mongo_update.dart';

class MongoAuthenticationRepository extends GetxController {
  static MongoAuthenticationRepository get instance => Get.find();

  final MongoFetch _mongoFetch = MongoFetch();
  final MongoInsert _mongoInsert = MongoInsert();
  final MongoUpdate _mongoUpdate = MongoUpdate();
  final MongoDelete _mongoDelete = MongoDelete();
  final String collectionName = 'users';
  final UserType userType = UserType.admin;
  // variable
  final _auth = FirebaseAuth.instance;
  // Upload multiple products
  Future<void> singUpWithEmailAndPass({required UserModel user}) async {
    try {
      // Check if a user with the same email or phone already exists
      final existingUser = await _mongoFetch.findOne(
        collectionName: collectionName,
         filter : {
                    r'$or': [
                      {UserFieldConstants.email: user.email},
                      {UserFieldConstants.phone: user.phone},
                    ]
                  },
        );
      if (existingUser != null) {
        throw 'Email or phone number already exists';
      }
      Map<String, dynamic> userMap = user.toMap();
      await _mongoInsert.insertDocument(collectionName, userMap); // Use batch insert function
    } catch (e) {
      throw 'Failed to create account: $e';
    }
  }

  // Upload multiple products
  Future<UserModel> loginWithEmailAndPass({required String email, required String password}) async {
    try {
      // Check if a user with the provided email exists
      final existingUser = await _mongoFetch.findOne(
        collectionName: collectionName,
        filter: {
          UserFieldConstants.email: email,
          UserFieldConstants.userType: userType.name,
        },
      );
      if (existingUser == null) {
        throw 'Invalid email or password'; // User not found
      }

      // Verify password using bcrypt
      if (!EncryptionHelper.comparePasswords(plainPassword: password, hashedPassword: existingUser['password'])) {//EncryptionHelper.
        throw 'Invalid email or password'; // Incorrect password
      }

      // Convert data to a UserModel
      final UserModel user = UserModel.fromJson(existingUser);
      return user; // Return the user object

      // User authenticated successfully (proceed with login session)
    } catch (e) {
      throw 'Failed login: $e';
    }
  }

  // Upload multiple products
  Future<UserModel> fetchUserByPhone({required String phone}) async {
    try {
      // Check if a user with the provided email exists
      final existingUser = await _mongoFetch.findOne(
        collectionName: collectionName,
        filter: {
          UserFieldConstants.phone: phone,
          UserFieldConstants.userType: userType.name, // assuming you're storing userType as a string like 'admin'
        },
      );

      if (existingUser == null) {
        throw 'Invalid user found for this phone number'; // User not found
      }

      // Convert data to a UserModel
      final UserModel user = UserModel.fromJson(existingUser);
      return user; // Return the user object

      // User authenticated successfully (proceed with login session)
    } catch (e) {
      throw 'Failed login: $e';
    }
  }

  // Upload multiple products
  Future<UserModel> fetchUserByEmail({required String email}) async {
    try {
      // Check if a user with the provided email exists
      final existingUser = await _mongoFetch.findOne(
        collectionName: collectionName,
        filter: {
          UserFieldConstants.email: email,
          UserFieldConstants.userType: userType.name, // assuming you're storing userType as a string like 'admin'
        },
      );

      if (existingUser == null) {
        throw 'Invalid user found for this email'; // User not found
      }

      // Convert data to a UserModel
      final UserModel user = UserModel.fromJson(existingUser);
      return user; // Return the user object

      // User authenticated successfully (proceed with login session)
    } catch (e) {
      throw 'Failed login: $e';
    }
  }

  // Upload multiple products
  Future<UserModel> fetchUserById({required String userId}) async {
    try {
      // Check if a user with the provided email exists
      final fetchedUser = await _mongoFetch.fetchDocumentById(
        collectionName: collectionName,
        id: userId,
      );

      // Convert data to a UserModel
      final UserModel user = UserModel.fromJson(fetchedUser);
      return user; // Return the user object

      // User authenticated successfully (proceed with login session)
    } catch (e) {
      throw 'user not found: $e';
    }
  }

  // Update a user document in a collection
  Future<void> updateUserByEmail({required String email, required UserModel user}) async {
    try {
      // Check if a user with the provided email exists
      final existingUser = await _mongoFetch.findOne(
          collectionName: collectionName,
          filter: {UserFieldConstants.email: email});

      if (existingUser == null) {
        throw 'Invalid user found for this email'; // User not found
      }

      user.userType =  UserType.admin;
      // Update user data in the database
      await _mongoUpdate.updateDocument(
        collectionName: collectionName,
        filter: {'email': email},
        updatedData: user.toMap()
      );
    } catch (e) {
      throw 'Failed to update user: $e';
    }
  }

  // Update a user document in a collection
  Future<void> updateUserById({required String id, required UserModel user}) async {
    try {
      await _mongoUpdate.updateDocumentById(
          collectionName: collectionName,
          id: id,
          updatedData: user.toMap()
      );
    } catch (e) {
      throw 'Failed to update user: $e';
    }
  }

  // Delete a purchase
  Future<void> deleteUser({required String id}) async {
    try {
      await _mongoDelete.deleteDocumentById(id: id, collectionName: collectionName);
    } catch (e) {
      throw 'Failed to Delete user: $e';
    }
  }


}