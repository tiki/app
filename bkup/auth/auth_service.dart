/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:app/src/slices/api/helpers/helper_api_rsp.dart';
import 'package:app/src/slices/app/model/api_user_model_current.dart';
import 'package:app/src/slices/app/model/api_user_model_user.dart';
import 'package:app/src/slices/app/repository/api_user_repository_current.dart';
import 'package:app/src/slices/app/repository/api_user_repository_user.dart';
import 'package:app/src/slices/auth/model/auth_model_token.dart';
import 'package:app/src/slices/auth/repository/api_bouncer_repository_jwt.dart';
import 'package:app/src/slices/auth/repository/api_bouncer_repository_otp.dart';
import 'package:app/src/slices/auth/repository/api_user_repository_otp.dart';
import 'package:app/src/slices/auth/repository/api_user_repository_token.dart';
import 'package:app/src/slices/keys/model/api_user_model_keys.dart';
import 'package:app/src/slices/keys/repository/api_user_repository_keys.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'model/auth_bouncer_jwt_req_otp.dart';
import 'model/auth_bouncer_jwt_rsp.dart';
import 'model/auth_bouncer_otp_req.dart';
import 'model/auth_bouncer_otp_rsp.dart';
import 'model/auth_model_otp.dart';

class AuthService {
  late SecureStorageRepositoryCurrent _secureStorageRepositoryCurrent;
  late SecureStorageRepositoryUser _repoLocalSsUser;
  late SecureStorageRepositoryKeys _repoLocalSsKeys;
  late SecureStorageRepositoryToken _repoLocalSsToken;
  late FlutterSecureStorage secureStorage;

  late AppModelCurrent current;

  AppModelUser? user;
  KeysModel? keys;
  AuthModelToken? token;

  bool _isOtp = false;
  get isOtp => _isOtp;

  AuthService() : secureStorage = FlutterSecureStorage() {
    _secureStorageRepositoryCurrent =
        SecureStorageRepositoryCurrent(secureStorage: secureStorage);
    _repoLocalSsUser =
        SecureStorageRepositoryUser(secureStorage: secureStorage);
    _repoLocalSsKeys =
        SecureStorageRepositoryKeys(secureStorage: secureStorage);
    _repoLocalSsToken =
        SecureStorageRepositoryToken(secureStorage: secureStorage);
  }

  Future<void> load() async {
    current = await _secureStorageRepositoryCurrent
        .find(SecureStorageRepositoryCurrent.key);
    if (current.email != null) {
      user = await _repoLocalSsUser.find(current.email!);
      if (user!.address != null)
        keys = await _repoLocalSsKeys.find(user!.address!);
      token = await _repoLocalSsToken.find(current.email!);
    }
  }

  Future<void> login(address) async {
    AppModelCurrent current = await _secureStorageRepositoryCurrent
        .find(SecureStorageRepositoryCurrent.key);
    await _repoLocalSsUser.save(current.email!,
        AppModelUser(email: current.email, address: address, isLoggedIn: true));
  }

  Future logout() async {
    user!.isLoggedIn = false;
    await _repoLocalSsUser.save(current.email!, user!);
    return user!;
  }

  Future<void> processOtpRequest(String email, String salt) async {
    current = AppModelCurrent(email: email);
    var ssOtp = AuthModelOtp(email: email, salt: salt);
    await SecureStorageRepositoryOtp()
        .save(SecureStorageRepositoryOtp.reqKey, ssOtp);
    await SecureStorageRepositoryCurrent()
        .save(SecureStorageRepositoryCurrent.key, current);
  }

  Future<bool> requestOtp(String email) async {
    HelperApiRsp<AuthModelOtpRsp> rsp =
        await AuthBouncerOtp.email(AuthModelOtpReq(email));
    if (rsp.code == 200) {
      await processOtpRequest(email, rsp.data.salt);
      return true;
    } else {
      return false;
    }
  }

  Future<AppModelUser?> verifyOtp(String otp) async {
    AuthModelOtp model = await SecureStorageRepositoryOtp()
        .find(SecureStorageRepositoryOtp.reqKey);
    if (model.email != null && model.salt != null) {
      HelperApiRsp<AuthBouncerJwtRsp> rsp =
          await AuthBouncerJwt.otp(AuthModelJwtReqOtp(otp, model.salt));
      if (rsp.code == 200) {
        AuthBouncerJwtRsp rspData = rsp.data;
        await SecureStorageRepositoryToken().save(
            model.email!,
            AuthModelToken(
                bearer: rspData.accessToken,
                refresh: rspData.refreshToken,
                expiresIn: rspData.expiresIn));
        var user = await SecureStorageRepositoryUser().find(model.email!);
        _isOtp = true;
        return user;
      }
    }
    SecureStorageRepositoryOtp().delete(SecureStorageRepositoryOtp.reqKey);
    _isOtp = false;
    return null;
  }
}
