import 'dart:convert';

import 'package:crypto/crypto.dart';

class PasswordHasher {
  const PasswordHasher._();

  static String hash(String value) {
    final bytes = utf8.encode(value);
    return sha256.convert(bytes).toString();
  }

  static bool verify(String plain, String hashed) {
    return hash(plain) == hashed;
  }
}
