import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../model/api_auth_service_account_model.dart';
import '../model/api_auth_service_provider_model.dart';

class ApiAuthServiceRepository {
  static const String _table = 'auth_service_account';
  final Database _database;
  static const _dbAuthProviders = "res/json/auth_providers_db.json";
  Map? providers;

  ApiAuthServiceRepository(this._database) {
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    String jsonString = await rootBundle.loadString(_dbAuthProviders);
    this.providers = jsonDecode(jsonString);
  }

  Future<ApiAuthServiceProviderModel?> getProvider(String providerName) async {
    if (providers == null) {
      await _loadProviders();
    }
    ApiAuthServiceProviderModel? providerModel =
        ApiAuthServiceProviderModel.fromMap(providers?[providerName]);
    return providerModel;
  }

  Future<ApiAuthServiceAccountModel> insert(
      ApiAuthServiceAccountModel account) async {
    DateTime now = DateTime.now();
    account.modified = now;
    account.created = now;
    int id = await _database.insert(_table, account.toMap());
    account.accountId = id;
    return account;
  }

  Future<ApiAuthServiceAccountModel> update(
      ApiAuthServiceAccountModel account) async {
    account.modified = DateTime.now();
    await _database.update(
      _table,
      account.toMap(),
      where: 'account_id = ?',
      whereArgs: [account.accountId],
    );
    return account;
  }

  Future<ApiAuthServiceAccountModel?> getById(int id) async {
    final List<Map<String, Object?>> rows =
        await _database.query(_table, where: "account_id = ?", whereArgs: [id]);
    if (rows.isEmpty) return null;
    return ApiAuthServiceAccountModel.fromMap(rows[0]);
  }

  Future<List<ApiAuthServiceAccountModel>> getByProvider(
      String provider) async {
    final List<Map<String, Object?>> rows = await _database
        .query(_table, where: "provider = ?", whereArgs: [provider]);
    if (rows.isEmpty) return [];
    return rows.map((e) => ApiAuthServiceAccountModel.fromMap(e)).toList();
  }

  Future<ApiAuthServiceAccountModel?> getByProviderAndUsername(
      String provider, String username) async {
    final List<Map<String, Object?>> rows = await _database.query(_table,
        where: "provider = ? AND username = ?",
        whereArgs: [provider, username]);
    if (rows.isEmpty) return null;
    return ApiAuthServiceAccountModel.fromMap(rows[0]);
  }
}
