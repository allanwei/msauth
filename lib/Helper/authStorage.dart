import 'dart:async';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';

import '../Model/user.dart';
import '../Model/token.dart';
import "dart:convert" as Convert;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static AuthStorage shared = new AuthStorage();
  dynamic _secureStorage = kIsWeb
      ? new PersistCookieJar(
          dir: "./cookies",
          ignoreExpires: true, //save/load even cookies that have expired.
        )
      : new FlutterSecureStorage();
  final String _identifier = "Token";
  final String _user = "User";

  Future<void> saveTokenToCache(Token token, User user) async {
    var data = Token.toJsonMap(token);
    var json = Convert.jsonEncode(data);
    await _secureStorage.write(key: _identifier, value: json);
    var userData = User.toJsonMap(user);
    var userJson = Convert.jsonEncode(userData);
    await _secureStorage.write(key: _user, value: userJson);
  }

  Future<T> loadTokenToCache<T extends Token>() async {
    var json = await _secureStorage.read(key: _identifier);
    if (json == null) return null;
    try {
      var data = Convert.jsonDecode(json);
      return _getTokenFromMap<T>(data);
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  Future<T> loadUserToCache<T extends User>() async {
    var json = await _secureStorage.read(key: _user);
    if (json == null) return null;
    try {
      var data = Convert.jsonDecode(json);
      return _getUserFromMap<T>(data);
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  Token _getTokenFromMap<T extends Token>(Map<String, dynamic> data) =>
      Token.fromJson(data);
  User _getUserFromMap<T extends User>(Map<String, dynamic> data) =>
      User.fromJson(data);

  Future clear() async {
    _secureStorage.delete(key: _identifier);
  }
}
