/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';

import '../../config/config_sentry.dart';
import '../../utils/api/helper_api_auth.dart';
import '../../utils/api/helper_api_rsp.dart';
import '../../utils/api/helper_api_utils.dart';
import '../../utils/helper_db.dart';
import '../api_app_data/api_app_data_service.dart';
import '../api_blockchain/api_blockchain_service.dart';
import '../api_blockchain/model/api_blockchain_model_address_req.dart';
import '../api_blockchain/model/api_blockchain_model_address_rsp.dart';
import '../api_bouncer/api_bouncer_service.dart';
import '../api_bouncer/model/api_bouncer_model_jwt_rsp.dart';
import '../api_bouncer/model/api_bouncer_model_otp_rsp.dart';
import '../api_company/api_company_service.dart';
import '../api_email_msg/api_email_msg_service.dart';
import '../api_email_sender/api_email_sender_service.dart';
import '../api_google/api_google_service.dart';
import '../api_user/api_user_service.dart';
import '../api_user/model/api_user_model_current.dart';
import '../api_user/model/api_user_model_keys.dart';
import '../api_user/model/api_user_model_otp.dart';
import '../api_user/model/api_user_model_token.dart';
import '../api_user/model/api_user_model_user.dart';
import '../data_bkg/data_bkg_service.dart';
import '../home_screen/home_screen_service.dart';
import '../intro_screen/intro_screen_service.dart';
import '../keys_create_screen/keys_create_screen_service.dart';
import '../keys_save_screen/keys_save_screen_service.dart';
import '../login_flow/login_flow_delegate.dart';
import '../login_screen_email/login_screen_email_service.dart';
import '../login_screen_inbox/login_screen_inbox_service.dart';
import 'model/login_flow_model.dart';
import 'model/login_flow_model_state.dart';

class LoginFlowService extends ChangeNotifier {
  final LoginFlowModel model;
  late final LoginFlowDelegate delegate;
  late final ApiUserService apiUserService;
  late final ApiBouncerService apiBouncerService;
  late final ApiBlockchainService apiBlockchainService;
  late final HelperApiAuth helperApiAuth;
  List<void Function()> logoutCallbacks = [];
  List<SingleChildWidget> providers = [];

  LoginFlowService() : this.model = LoginFlowModel() {
    this.delegate = LoginFlowDelegate(this);
    initDynamicLinks();
  }

  Future<void> initialize(
      {required ApiUserService apiUserService,
      required ApiBouncerService apiBouncerService,
      required ApiBlockchainService apiBlockchainService,
      required HelperApiAuth helperApiAuth,
      Iterable<void Function()>? logoutCallbacks}) async {
    this.apiUserService = apiUserService;
    this.apiBouncerService = apiBouncerService;
    this.apiBlockchainService = apiBlockchainService;
    this.helperApiAuth = helperApiAuth;
    if (logoutCallbacks != null) this.logoutCallbacks.addAll(logoutCallbacks);
    await loadUser();

    if (this.model.user?.user?.isLoggedIn == true) {
      await _initServices();
      setLoggedIn();
    } else if (this.model.user?.current?.email != null) setReturningUser();
  }

  Future<void> loadUser() async {
    this.model.user = await apiUserService.get();
    notifyListeners();
  }

  bool onPopPage(Route<dynamic> route, result) {
    if (!route.didPop(result)) return false;

    if (this.model.state == LoginFlowModelState.otpRequested)
      this.model.state = LoginFlowModelState.returningUser;

    //TODO check if we need/want to explicitly exit the app on back btn.

    notifyListeners();
    return true;
  }

  List<Page> getPages() {
    return [
      IntroScreenService().presenter,
      if (this.model.state == LoginFlowModelState.returningUser)
        LoginScreenEmailService(this).presenter
      else if (this.model.state == LoginFlowModelState.otpRequested)
        LoginScreenInboxService(this).presenter
      else if (this.model.state == LoginFlowModelState.creatingKeys)
        KeysCreateScreenService(this).presenter
      else if (this.model.state == LoginFlowModelState.keysCreated)
        KeysSaveScreenService(this).presenter
      else if (this.model.state == LoginFlowModelState.loggedIn)
        HomeScreenService(providers: providers).presenter
    ];
  }

  void registerLogout(void Function() logout) {
    if (!this.logoutCallbacks.contains(logout))
      this.logoutCallbacks.add(logout);
  }

  void changeState(LoginFlowModelState state) {
    this.model.state = state;
    notifyListeners();
  }

  void setReturningUser() => changeState(LoginFlowModelState.returningUser);

  void setOtpRequested() => changeState(LoginFlowModelState.otpRequested);

  void setCreatingKeys() => changeState(LoginFlowModelState.creatingKeys);

  void setKeysCreated() => changeState(LoginFlowModelState.keysCreated);

  void setLoggedIn() => changeState(LoginFlowModelState.loggedIn);

  void setLoggedOut() async {
    if (this.model.user?.user?.isLoggedIn == true) {
      this.model.user!.user!.isLoggedIn = false;
      await apiUserService.setUser(this.model.user!.user!);
    }
    logoutCallbacks.forEach((func) => func());
    setReturningUser();
  }

  Future<void> initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;
      if (deepLink != null) _dynamicLinkHandler(deepLink);
    }, onError: (OnLinkErrorException e) async {
      ConfigSentry.exception(e, stackTrace: StackTrace.current);
    });
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink != null) _dynamicLinkHandler(deepLink);
  }

  Future<bool> requestOtp({String? email}) async {
    bool success = false;

    if (email != null) {
      this.model.user?.current = ApiUserModelCurrent(email: email);
      apiUserService.setCurrent(email);
    }

    setOtpRequested();
    HelperApiRsp<ApiBouncerModelOtpRsp> rsp =
        await apiBouncerService.otpRequest(this.model.user!.current!.email!);

    if (HelperApiUtils.isOk(rsp.code)) {
      ApiBouncerModelOtpRsp data = rsp.data;
      apiUserService.setOtp(ApiUserModelOtp(
          email: this.model.user!.current!.email!, salt: data.salt));
      success = true;
    } else
      setReturningUser();

    await loadUser();
    return success;
  }

  Future<void> _dynamicLinkHandler(Uri link) async {
    final String dlPathBouncer = "/app/bouncer";
    if (link.path == dlPathBouncer) {
      String? otp = link.queryParameters["otp"];
      if (otp != null && otp.isNotEmpty) {
        if (!await verifyOtp(otp)) setLoggedOut(); //logout
      }
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (this.model.user!.user!.isLoggedIn == true) return true;
    HelperApiRsp<ApiBouncerModelJwtRsp> rsp =
        await apiBouncerService.otpGrant(otp, this.model.user!.otp!.salt!);
    if (HelperApiUtils.isOk(rsp.code)) {
      ApiBouncerModelJwtRsp data = rsp.data;
      await apiUserService.setToken(
          this.model.user!.current!.email!,
          ApiUserModelToken(
              bearer: data.accessToken,
              refresh: data.refreshToken,
              expiresIn: data.expiresIn));

      if (this.model.user?.keys?.address != null) {
        this.model.user!.user!.isLoggedIn = true;
        await apiUserService.setUser(this.model.user!.user!);
        await _initServices();
        setLoggedIn();
      } else {
        await apiUserService.setUser(ApiUserModelUser(
            email: this.model.user!.current!.email!, isLoggedIn: false));
        setCreatingKeys();
      }
      await loadUser();
      return true;
    } else
      return false;
  }

  Future<bool> registerAndLogin({ApiUserModelKeys? keys}) async {
    if (await _saveKeys(keys: keys)) {
      if (await _registerKeys(keys: keys)) {
        await _initServices();
        setLoggedIn();
        await loadUser();
        return true;
      }
    }
    return false;
  }

  Future<bool> saveAndLogin({ApiUserModelKeys? keys}) async {
    if (await _saveKeys(keys: keys)) {
      await _initServices();
      setLoggedIn();
      await loadUser();
      return true;
    }
    return false;
  }

  Future<bool> _saveKeys({ApiUserModelKeys? keys}) async {
    if (keys != null) this.model.user!.keys = keys;
    if (this.model.user?.keys != null) {
      await this.apiUserService.setKeys(this.model.user!.keys!);
      this.model.user!.user!.address = this.model.user!.keys!.address;
      this.model.user!.user!.isLoggedIn = true;
      await this.apiUserService.setUser(this.model.user!.user!);
      return true;
    } else {
      ConfigSentry.message("Trying to save null keys. Skipping",
          level: ConfigSentry.levelError);
      return false;
    }
  }

  Future<bool> _registerKeys({ApiUserModelKeys? keys}) async {
    if (keys != null) this.model.user!.keys = keys;
    HelperApiRsp<ApiBlockchainModelAddressRsp> rsp = await this
        .apiBlockchainService
        .issue(ApiBlockchainModelAddressReq(
            this.model.user?.keys!.dataPublicKey,
            this.model.user?.keys!.signPublicKey));
    if (HelperApiUtils.isOk(rsp.code)) {
      ApiBlockchainModelAddressRsp data = rsp.data;
      if (data.address != this.model.user!.keys!.address) {
        ConfigSentry.message("Failed to issue Blockchain Address.Skipping",
            level: ConfigSentry.levelError);
        return false;
      }
    } else {
      ConfigSentry.message("Failed to issue Blockchain Address.Skipping",
          level: ConfigSentry.levelError);
      return false;
    }
    return true;
  }

  Future<void> _initServices() async {
    Database database =
        await HelperDb().open(this.model.user!.keys!.signPrivateKey!);

    ApiAppDataService apiAppDataService = ApiAppDataService(database: database);
    ApiEmailSenderService apiEmailSenderService =
        ApiEmailSenderService(database: database);
    ApiEmailMsgService apiEmailMsgService =
        ApiEmailMsgService(database: database);
    ApiCompanyService apiCompanyService =
        ApiCompanyService(database: database, helperApiAuth: helperApiAuth);

    ApiGoogleService apiGoogleService = ApiGoogleService();
    registerLogout(() async => await apiGoogleService.signOut());

    DataBkgService dataBkgService = DataBkgService(
        apiEmailMsgService: apiEmailMsgService,
        apiCompanyService: apiCompanyService,
        apiEmailSenderService: apiEmailSenderService,
        apiGoogleService: apiGoogleService,
        apiAppDataService: apiAppDataService);

    providers = [
      Provider<ApiCompanyService>.value(value: apiCompanyService),
      Provider<ApiEmailSenderService>.value(value: apiEmailSenderService),
      Provider<ApiEmailMsgService>.value(value: apiEmailMsgService),
      Provider<ApiAppDataService>.value(value: apiAppDataService),
      Provider<ApiGoogleService>.value(value: apiGoogleService),
      ChangeNotifierProvider<DataBkgService>.value(value: dataBkgService),
    ];
  }
}
