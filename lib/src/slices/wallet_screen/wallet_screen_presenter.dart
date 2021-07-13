/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'ui/wallet_screen_layout.dart';
import 'wallet_screen_service.dart';

class WalletScreenPresenter extends Page {
  final WalletScreenService service;

  WalletScreenPresenter(this.service) : super(key: ValueKey("WalletScreen"));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => ChangeNotifierProvider.value(
          value: service, child: WalletScreenLayout()),
    );
  }
}
