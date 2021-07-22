import 'package:app/src/slices/api_background/api_background_service.dart';
import 'package:app/src/slices/api_blockchain/api_blockchain_service.dart';
import 'package:app/src/slices/api_bouncer/api_bouncer_service.dart';
import 'package:app/src/slices/api_company/api_company_service.dart';
import 'package:app/src/slices/api_company_index/api_company_index_service.dart';
import 'package:app/src/slices/api_google/api_google_service.dart';
import 'package:app/src/slices/api_message/api_message_service.dart';
import 'package:app/src/slices/api_sender/api_sender_service.dart';
import 'package:app/src/slices/api_signup/api_signup_service.dart';
import 'package:app/src/slices/api_user/api_user_service.dart';
import 'package:app/src/slices/login_flow/login_flow_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'src/utils/api/helper_api_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();

  ApiUserService apiUserService = ApiUserService(FlutterSecureStorage());
  LoginFlowService loginFlowService = LoginFlowService();
  ApiBouncerService apiBouncerService = ApiBouncerService();
  HelperApiAuth helperApiAuth =
      HelperApiAuth(loginFlowService, apiBouncerService);
  ApiBlockchainService apiBlockchainService =
      ApiBlockchainService(helperApiAuth);
  ApiCompanyIndexService apiCompanyIndexService =
      ApiCompanyIndexService(helperApiAuth);
  ApiGoogleService apiGoogleService = ApiGoogleService();
  ApiCompanyService apiCompanyService =
      ApiCompanyService(apiCompanyIndexService);
  ApiSenderService apiSenderService = ApiSenderService();
  ApiMessageService apiMessageService = ApiMessageService();
  ApiBackgroundService apiBackgroundService = ApiBackgroundService(
    googleService: apiGoogleService,
    companyService: apiCompanyService,
    senderService: apiSenderService,
    messageService: apiMessageService,
  );
  ApiSignupService apiSignupService = ApiSignupService();

  await loginFlowService.initialize(
      apiUserService: apiUserService,
      apiBouncerService: apiBouncerService,
      apiBlockchainService: apiBlockchainService,
      logoutCallbacks: [() async => await apiGoogleService.signOut()]);
  //TODO: reactivate sentry for launch
  // SentryFlutter.init(
  //     (options) async => options
  //       ..dsn = ConfigSentry.dsn
  //       ..environment = ConfigSentry.environment
  //       ..release = (await PackageInfo.fromPlatform()).version
  //       ..sendDefaultPii = false,
  //     appRunner: () =>
  runApp(MultiProvider(
    providers: [
      Provider<ApiUserService>.value(value: apiUserService),
      Provider<ApiBouncerService>.value(value: apiBouncerService),
      Provider<ApiBlockchainService>.value(value: apiBlockchainService),
      Provider<ApiSignupService>.value(value: apiSignupService),
      Provider<ApiGoogleService>.value(value: apiGoogleService),
      Provider<ApiCompanyIndexService>.value(value: apiCompanyIndexService),
      Provider<ApiCompanyService>.value(value: apiCompanyService),
      Provider<ApiSenderService>.value(value: apiSenderService),
      Provider<ApiMessageService>.value(value: apiMessageService),
      Provider<ApiBackgroundService>.value(value: apiBackgroundService)
    ],
    child: App(loginFlowService),
  ));
  //);
}
