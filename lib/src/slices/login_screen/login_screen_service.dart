import 'package:app/src/slices/app/app_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'login_screen_controller.dart';
import 'login_screen_presenter.dart';
import 'model/login_screen_model.dart';

class LoginScreenService extends ChangeNotifier {
  late LoginScreenModel model;
  late LoginScreenPresenter presenter;
  late LoginScreenController controller;

  LoginScreenService() {
    model = LoginScreenModel();
    controller = LoginScreenController();
    presenter = LoginScreenPresenter(this);
  }

  bool _isValidEmail() {
    return EmailValidator.validate(this.model.email);
  }

  void onEmailChange(String email) {
    this.model.email = email;
    this.model.canSubmit = _isValidEmail();
    notifyListeners();
  }

  Future<void> submitEmail(BuildContext context) async {
    if (this.model.canSubmit) {
      otpSubmitted();
      AppService appService = Provider.of<AppService>(context, listen: false);
      var result = await appService.requestOtp(this.model.email);
      if (!result) otpError();
    }
  }

  void otpError() {
    this.model.submitted = false;
    this.model.isError = true;
    notifyListeners();
  }

  Page getUI() {
    return this.presenter;
  }

  void otpSubmitted() {
    this.model.submitted = true;
    this.model.isError = false;
    notifyListeners();
  }

  void clearModel() {
    this.model.submitted = false;
    this.model.isError = false;
    notifyListeners();
  }

  void back() {
    this.model.submitted = false;
    notifyListeners();
  }

  void resend(BuildContext context) {
    submitEmail(context);
  }
}
