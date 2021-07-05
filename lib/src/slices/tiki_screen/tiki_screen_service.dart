import 'package:app/src/slices/api/api_service.dart';
import 'package:app/src/slices/app/app_service.dart';
import 'package:app/src/slices/app/model/app_model_user.dart';
import 'package:app/src/slices/google/google_service.dart';
import 'package:app/src/slices/info_carousel/info_carousel_service.dart';
import 'package:app/src/slices/info_carousel_card/model/info_carousel_card_model.dart';
import 'package:app/src/slices/tiki_screen/tiki_screen_controller.dart';
import 'package:app/src/slices/tiki_screen/tiki_screen_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'model/tiki_screen_model.dart';

class TikiScreenService extends ChangeNotifier {
  static const String _linkUrl = "https://mytiki.com/";
  late TikiScreenModel model;
  late TikiScreenPresenter presenter;
  late TikiScreenController controller;

  GoogleService googleService = GoogleService();

  TikiScreenService() {
    model = TikiScreenModel();
    controller = TikiScreenController();
    presenter = TikiScreenPresenter(this);
    initializeGoogleRepo();
    getValues();
  }

  getCode(BuildContext context) {
    AppModelUser user = Provider.of<AppService>(context).model.user!;
    this.model.code = user.code ?? "";
    if (this.model.code.isEmpty) updateCode(context);
  }

  getReferCount() async {
    var code = this.model.code;
    var apiService = ApiService();
    apiService.getReferCount(code);
  }

  getTotalCount() async {
    var apiService = ApiService();
    var total = await apiService.getTotal();
    this.model.count = total;
  }

  void getValues() async {
    await getTotalCount();
    await getReferCount();
    await getVersion();
    notifyListeners();
  }

  Widget getUI() {
    return this.presenter.render();
  }

  void addGoogleAccount() async {
    this.model.googleAccount = await googleService.connect();
    notifyListeners();
  }

  void removeGoogleAccount() async {
    await googleService.handleSignOut();
    this.model.googleAccount = null;
    notifyListeners();
  }

  initializeGoogleRepo() async {
    googleService = GoogleService();
    this.model.googleAccount = await googleService.getConnectedUser();
    notifyListeners();
  }

  void shareLink() {
    var code = this.model.code;
    var body =
        "Your data. Your decisions. Take the take power back from corporations. Together, we triumph. Join us! " +
            _linkUrl +
            code;
    Share.share(body, subject: "Have you seen this???");
  }

  Future<void> copyLink() async {
    var code = this.model.code;
    await Clipboard.setData(new ClipboardData(text: _linkUrl + code));
  }

  Future<void> whatGmailHolds(context) async {
    List<InfoCarouselCardModel> cards = await googleService.getInfoCards();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => InfoCarouselService(cards: cards).getUI()));
  }

  Future<void> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    this.model.version = packageInfo.version;
    notifyListeners();
  }

  void updateCode(BuildContext context) async {
    var apiService = ApiService();
    AppService appService = Provider.of<AppService>(context);
    AppModelUser user = appService.model.user!;
    apiService.getReferralCode(user.address!).then((referral) async {
      this.model.code = referral;
      user.code = this.model.code;
      await appService.updateUser(user);
      notifyListeners();
    }).onError((error, stackTrace) {
      // SEND TO SENTRY
      controller.logout(context);
    });
  }
}
