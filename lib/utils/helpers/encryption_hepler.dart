import 'package:bcrypt/bcrypt.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EncryptionHelper {
  static final String encrypterKey = dotenv.get('ENCRYPTER_KEY', fallback: 'default32characterslongsecretkey!');
  static final int encrypterLength = int.tryParse(dotenv.get('ENCRYPTER_LENGTH', fallback: '16')) ?? 16;

  static final _key = encrypt.Key.fromUtf8(encrypterKey); // should be 16, 24, or 32 bytes

  /// Encrypts text and returns [ivBase64]:[encryptedBase64]
  static String encryptText(String plainText) {
    final iv = encrypt.IV.fromSecureRandom(encrypterLength);
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts string in format [ivBase64]:[encryptedBase64]
  static String decryptText(String encryptedText) {
    final parts = encryptedText.split(':');
    if (parts.length != 2) {
      throw ArgumentError('Invalid encrypted text format. Expected format: ivBase64:encryptedBase64');
    }

    final iv = encrypt.IV.fromBase64(parts[0]);
    final encryptedBase64 = parts[1];

    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    return encrypter.decrypt64(encryptedBase64, iv: iv);
  }

  // Function to hash the password using bcrypt
  static String hashPassword({required String password}) {
    String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
    return hashedPassword;
  }

  // Function to compare a plaintext password with a hashed password
  static bool comparePasswords({required String plainPassword, required String hashedPassword}) {
    return BCrypt.checkpw(plainPassword, hashedPassword);
  }
}
