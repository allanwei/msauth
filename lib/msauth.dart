library msauth;

import 'dart:convert';

import 'Model/config.dart';
import 'package:flutter/material.dart';
import 'Helper/authStorage.dart';
import 'Model/token.dart';
import 'Model/user.dart';
import 'request_code.dart';
import 'request_token.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';


/// A Calculator.
class MsAuth {
  static Config _config;
  AuthStorage _authStorage;
  Token _token;
  RequestCode _requestCode;
  RequestToken _requestToken;
  User _user;

  factory MsAuth(config) {
    if (MsAuth._instance == null) {
      MsAuth._instance = new MsAuth._internal(config);
      
    }
    return _instance;
  }

  static MsAuth _instance;

  MsAuth._internal(config) {
    MsAuth._config = config;
    _authStorage = _authStorage ?? new AuthStorage();
    _requestCode = new RequestCode(_config);
    _requestToken = new RequestToken(_config);
  }
  void setWebViewScreenSize(Rect screenSize) {
    _config.screenSize = screenSize;
  }
  Future<void> login() async {
    await _removeOldTokenOnFirstLogin();
    if (!Token.tokenIsValid(_token) )
      await _performAuthorization();
  }

  Future<String> getAccessToken() async {
    if (!Token.tokenIsValid(_token) )
      await _performAuthorization();

    return _token.accessToken;
  }
 Future<String>getRefreshToken()async{
   if(!Token.tokenIsValid(_token)){
      await _performRefreshAuthFlow();
   }
   return _token.accessToken;
 }
  bool tokenIsValid() {
    return Token.tokenIsValid(_token);
  }

  Future<void> logout() async {
    await _authStorage.clear();
    await _requestCode.clearCookies();
    _token = null;
    MsAuth(_config);
  }
  Future<User> getUser() async{
     return  await _authStorage.loadUserToCache();
  }
  Future<void> _performAuthorization() async {
    // load token from cache
    _token = await _authStorage.loadTokenToCache();
    _user = await _authStorage.loadUserToCache();

    //still have refreh token / try to get new access token with refresh token
    if (_token != null){
      await _performRefreshAuthFlow();
      }

    // if we have no refresh token try to perform full request code oauth flow
    else {
      try {
        await _performFullAuthFlow();
      } catch (e) {
        rethrow;
      }
    }
    await _getUser();  
    //save token to cache
    await _authStorage.saveTokenToCache(_token,_user);
  }
  Future<void> _getUser() async{
    try{
      final parts=_token.accessToken.split('.');
      final payload = parts[1];
        final String decoded = B64urlEncRfc7515.decodeUtf8(payload);
        _user = User.fromJson(json.decode(decoded));
        _user.accessToken=_token.accessToken;
        _user.refreshToken=_token.refreshToken;
    }catch(e){
      rethrow;
    }

  }
  Future<void> _performFullAuthFlow() async {
    String code;
    try {
      code = await _requestCode.requestCode();
      _token = await _requestToken.requestToken(code);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _performRefreshAuthFlow() async {
    if (_token.refreshToken != null) {
      try {
        _token = await _requestToken.requestRefreshToken(_token.refreshToken);
      } catch (e) {
        //do nothing (because later we try to do a full oauth code flow request)
      }
    }
  }

  Future<void> _removeOldTokenOnFirstLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _keyFreshInstall = "freshInstall";
    if (!prefs.getKeys().contains(_keyFreshInstall)) {
      logout();
      await prefs.setBool(_keyFreshInstall, false);
    }
  }
}
