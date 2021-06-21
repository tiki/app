/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import 'package:app/src/config/config_domain.dart';
import 'package:app/src/repositories/api/helper_api_rsp.dart';
import 'package:app/src/repositories/api/helper_headers.dart';
import 'package:http/http.dart' as http;

import 'repo_api_website_users_rsp.dart';

class RepoApiWebsiteUsers {
  static const String _path = '/api/0-1-0/user';

  Future<HelperApiRsp<RepoApiWebsiteUsersRsp>> total() async {
    http.Response rsp = await http.get(
        ConfigDomain.asUri(ConfigDomain.website, _path),
        headers: HelperHeaders().header);
    Map? rspMap = jsonDecode(rsp.body);
    return HelperApiRsp(
        code: rsp.statusCode,
        data: RepoApiWebsiteUsersRsp.fromJson(rspMap as Map<String, dynamic>?));
  }
}