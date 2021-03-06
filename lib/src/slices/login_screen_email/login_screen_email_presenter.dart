/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:app/src/slices/login_screen_email/ui/login_screen_email_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen_email_service.dart';

class LoginScreenEmailPresenter extends Page {
  final LoginScreenEmailService service;

  LoginScreenEmailPresenter(this.service)
      : super(key: ValueKey("LoginScreenEmail"));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (BuildContext context) => ChangeNotifierProvider.value(
            value: service, child: LoginScreenEmailLayout()));
  }
}
