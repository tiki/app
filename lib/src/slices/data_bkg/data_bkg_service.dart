/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';

import '../api_app_data/api_app_data_key.dart';
import '../api_app_data/api_app_data_service.dart';
import '../api_app_data/model/api_app_data_model.dart';
import '../api_auth_service/api_auth_service.dart';
import '../api_auth_service/model/api_auth_service_account_model.dart';
import '../api_company/api_company_service.dart';
import '../api_company/model/api_company_model_local.dart';
import '../api_email_msg/api_email_msg_service.dart';
import '../api_email_msg/model/api_email_msg_model.dart';
import '../api_email_sender/api_email_sender_service.dart';
import '../api_email_sender/model/api_email_sender_model.dart';
import '../api_google/api_google_service.dart';
import 'model/data_bkg_model.dart';
import 'model/data_bkg_model_page.dart';

class DataBkgService extends ChangeNotifier {
  final _log = Logger('DataBkgService');
  final DataBkgModel model = DataBkgModel();
  final ApiCompanyService _apiCompanyService;
  final ApiEmailMsgService _apiEmailMsgService;
  final ApiEmailSenderService _apiEmailSenderService;
  final ApiGoogleService _apiGoogleService;
  final ApiAppDataService _apiAppDataService;
  final ApiAuthService _apiAuthService;

  DataBkgService(
      {required ApiGoogleService apiGoogleService,
      required ApiCompanyService apiCompanyService,
      required ApiEmailMsgService apiEmailMsgService,
      required ApiEmailSenderService apiEmailSenderService,
      required ApiAppDataService apiAppDataService,
      required ApiAuthService apiAuthService})
      : this._apiGoogleService = apiGoogleService,
        this._apiCompanyService = apiCompanyService,
        this._apiEmailMsgService = apiEmailMsgService,
        this._apiEmailSenderService = apiEmailSenderService,
        this._apiAuthService = apiAuthService,
        this._apiAppDataService = apiAppDataService {
    checkGmail();
  }

  Future<void> checkGmail({bool fetchAll = false, bool force = false}) async {
    _log.fine('Gmail fetch starting on: ' + DateTime.now().toIso8601String());
    GoogleSignInAccount? googleAccount =
        await _apiGoogleService.getConnectedUser();
    if (googleAccount == null) {
      _log.fine('Gmail fetch aborted. No Google Account.');
      return;
    }
    ApiAppDataModel? appDataGmailLastFetch =
        await _apiAppDataService.getByKey(ApiAppDataKey.gmailLastFetch);
    int? gmailLastFetchEpoch = fetchAll || appDataGmailLastFetch == null
        ? null
        : int.parse(appDataGmailLastFetch.value);
    if (force == true ||
        gmailLastFetchEpoch == null ||
        DateTime.now().subtract(Duration(days: 1)).isAfter(
            DateTime.fromMillisecondsSinceEpoch(gmailLastFetchEpoch))) {
      DateTime run = DateTime.now();
      String activeCategory =
          (await _apiAppDataService.getByKey(ApiAppDataKey.gmailCategory))
                  ?.value ??
              model.gmailCategoryList[0];
      int categoryStartIndex = model.gmailCategoryList.indexOf(activeCategory);
      int totalCats = model.gmailCategoryList.length;
      for (int i = categoryStartIndex; i < totalCats; i++) {
        String category = model.gmailCategoryList[i];
        String query = _gmailBuildQuery(gmailLastFetchEpoch, category);
        await _checkGmailFetchList(query: query);
        int nextCatIndex = model.gmailCategoryList.indexOf(category) + 1;
        String nextCat = nextCatIndex == totalCats
            ? model.gmailCategoryList[0]
            : model.gmailCategoryList[nextCatIndex];
        await _apiAppDataService.save(ApiAppDataKey.gmailCategory, nextCat);
      }
      await _apiAppDataService.save(
          ApiAppDataKey.gmailLastFetch, run.millisecondsSinceEpoch.toString());
      await _apiAppDataService.save(ApiAppDataKey.gmailPage, '');
      _log.fine(
          'Gmail fetch completed on: ' + DateTime.now().toIso8601String());
    }
  }

  Future<void> _checkGmailFetchList({String query = ''}) async {
    String? page;
    ApiAppDataModel? appDataGmailPage =
        await _apiAppDataService.getByKey(ApiAppDataKey.gmailPage);
    page = appDataGmailPage?.value;
    return _checkGmailFetchListPage(query: query, page: page);
  }

  Future<void> _checkGmailFetchListPage({String? page, String? query}) async {
    DataBkgModelPage<String> res = await _apiGoogleService.gmailFetch(
        query: query, page: page, maxResults: 5);
    if (res.data != null) {
      List<String> known =
          (await _apiEmailMsgService.getByExtMessageIds(res.data!))
              .map((message) => message.extMessageId!)
              .toList();
      List<String> unknown =
          res.data!.where((message) => !known.contains(message)).toList();
      await _checkGmailFetchMessage(unknown);
    }
    await _apiAppDataService.save(ApiAppDataKey.gmailPage, res.next ?? '');
    if (res.next != null)
      return _checkGmailFetchListPage(page: res.next, query: query);
  }

  Future<void> _checkGmailFetchMessage(List<String> messages) async {
    Set<String> processed = Set();
    for (String messageId in messages) {
      ApiEmailMsgModel? message = await _apiGoogleService.gmailFetchMessage(
          messageId,
          format: "metadata",
          headers: ["List-unsubscribe"]);
      if (message?.extMessageId != null) processed.add(message!.extMessageId!);
      if (message?.sender?.email != null &&
          message?.sender?.unsubscribeMailTo != null) {
        ApiEmailSenderModel? sender =
            await _apiEmailSenderService.getByEmail(message!.sender!.email!);
        if (sender != null) {
          await _saveSender(sender);
          await _apiEmailMsgService.upsert(message);
          _log.fine('Sender upsert: ' + (sender.company?.domain ?? ''));
          notifyListeners();
        } else {
          Set<ApiEmailMsgModel> senderMessages =
              await _checkGmailNewSender(message.sender!.email!);
          Set<String> senderMessageIds =
              senderMessages.map((message) => message.extMessageId!).toSet();
          List<String> newMessages = messages
              .where((message) =>
                  !senderMessageIds.contains(message) &&
                  !processed.contains(message))
              .toList();
          return _checkGmailFetchMessage(newMessages);
        }
      }
    }
  }

  Future<Set<ApiEmailMsgModel>> _checkGmailNewSender(String email) async {
    List<String> messageIds = await _checkGmailNewSenderPage(
        email: email, messages: List.empty(growable: true));
    Set<ApiEmailMsgModel> messages = Set();
    DateTime first = DateTime.now();
    for (String messageId in messageIds) {
      ApiEmailMsgModel? message = await _apiGoogleService.gmailFetchMessage(
          messageId,
          format: "metadata",
          headers: ["List-unsubscribe"]);
      if (message?.sender?.email != null &&
          message?.sender?.unsubscribeMailTo != null) {
        messages.add(message!);
        if (message.receivedDate != null &&
            message.receivedDate!.isBefore(first))
          first = message.receivedDate!;
      }
    }
    ApiEmailSenderModel sender = messages.first.sender!;
    sender.emailSince = first;
    ApiEmailSenderModel? inserted = await _saveSender(sender);
    if (inserted != null) {
      for (ApiEmailMsgModel message in messages) {
        message.sender = inserted;
        await _apiEmailMsgService.upsert(message);
      }
      _log.fine('Sender upsert: ' + (sender.company?.domain ?? ''));
      notifyListeners();
    }
    return messages;
  }

  Future<List<String>> _checkGmailNewSenderPage(
      {required String email,
      String? page,
      required List<String> messages}) async {
    DataBkgModelPage<String> res =
        await _apiGoogleService.gmailFetch(query: 'from:' + email, page: page);
    if (res.data != null) messages.addAll(res.data!);
    if (res.next != null)
      return _checkGmailNewSenderPage(
          email: email, page: res.next, messages: messages);
    else
      return messages;
  }

  Future<ApiEmailSenderModel?> _saveSender(ApiEmailSenderModel sender) async {
    if (sender.email != null) {
      ApiCompanyModelLocal? company =
          await _apiCompanyService.upsert(domainFromEmail(sender.email!));
      if (company != null) {
        sender.company = company;
        ApiEmailSenderModel saved = await _apiEmailSenderService.upsert(sender);
        return saved;
      }
    }
  }

  String domainFromEmail(String email) {
    List<String> atSplit = email.split('@');
    List<String> periodSplit = atSplit[atSplit.length - 1].split('.');
    return periodSplit[periodSplit.length - 2] +
        "." +
        periodSplit[periodSplit.length - 1];
  }

  Future<void> addAccount(String providerName,
      {List<String> aditionalScopes = const []}) async {
    List<String> scopes = [...aditionalScopes, "openid", "profile", "email"];
    AuthorizationTokenResponse? tokenResponse = await _apiAuthService
        .authorizeAndExchangeCode(providerName: providerName, scopes: scopes);
    if (tokenResponse != null) {
      // TODO get account data to get username
      ApiAuthServiceAccountModel apiAuthServiceAccountModel =
          ApiAuthServiceAccountModel(
              provider: providerName,
              accessToken: tokenResponse.accessToken,
              accessTokenExpiration: tokenResponse
                  .accessTokenExpirationDateTime?.millisecondsSinceEpoch,
              refreshToken: tokenResponse.refreshToken,
              shouldReconnect: 0);
      await _apiAuthService.upsert(apiAuthServiceAccountModel);
    }
  }

  String _gmailBuildQuery(int? fetchEpochInMilliseconds, String category) {
    StringBuffer queryBuffer = new StringBuffer();
    if (fetchEpochInMilliseconds != null) {
      int secondsSinceEpoch = (fetchEpochInMilliseconds / 1000).floor();
      _gmailAppendQuery(queryBuffer, "after:" + secondsSinceEpoch.toString());
    }
    if (category != 'category:' && category.isNotEmpty) {
      _gmailAppendQuery(queryBuffer, category);
    } else {
      model.gmailCategoryList
          .where((cat) => cat != 'category:')
          .forEach((cat) => _gmailAppendQuery(queryBuffer, 'NOT $cat'));
    }
    return queryBuffer.toString();
  }

  StringBuffer _gmailAppendQuery(StringBuffer queryBuffer, String append) {
    if (queryBuffer.isNotEmpty) {
      queryBuffer.write(" AND ");
    }
    queryBuffer.write(append);
    return queryBuffer;
  }
}
