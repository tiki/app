import 'dart:convert';

class ApiAuthServiceAccountModel {
  int? accountId;
  String? username;
  String? provider;
  String? accessToken;
  int? accessTokenExpiration;
  String? refreshToken;
  String? _scopes;
  int? refreshTokenExpiration;
  int? shouldReconnect;
  DateTime? modified;
  DateTime? created;

  List<String> get scopes => jsonDecode(_scopes ?? "[]");

  set scopes(List<String> scopeList) => jsonEncode(scopeList);

  ApiAuthServiceAccountModel(
      {this.accountId,
      this.username,
      this.provider,
      this.accessToken,
      this.accessTokenExpiration,
      this.refreshToken,
      List<String>? scopeList,
      this.refreshTokenExpiration,
      this.shouldReconnect}) {
    this.scopes = scopeList ?? [];
  }

  ApiAuthServiceAccountModel.fromMap(map) {
    this.accountId = map['account_id'];
    this.username = map['username'];
    this.provider = map['provider'];
    this.accessToken = map['access_token'];
    this.accessTokenExpiration = map['access_token_expiration'];
    this.refreshToken = map['refreshToken'];
    this.refreshTokenExpiration = map['refresh_token_expiration'];
    this.shouldReconnect = map['should_reconnect'] ?? 0;
    if (map['modified_epoch'] != null)
      this.modified =
          DateTime.fromMillisecondsSinceEpoch(map['modified_epoch']);
    if (map['created_epoch'] != null)
      this.created = DateTime.fromMillisecondsSinceEpoch(map['created_epoch']);
  }

  Map<String, dynamic> toMap() =>
      {
        'account_id': accountId,
        'username': username,
        'provider': provider,
        'access_token': accessToken,
        'access_token_expiration': accessTokenExpiration,
        'refresh_token': refreshToken,
        'refresh_token_expiration': refreshTokenExpiration,
        'should_reconnect': shouldReconnect,
        'modified_epoch': modified?.millisecondsSinceEpoch,
        'created_epoch': created?.millisecondsSinceEpoch
      };
}
