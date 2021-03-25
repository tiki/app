/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:app/src/constants/constant_colors.dart';
import 'package:app/src/constants/constant_sizes.dart';
import 'package:app/src/constants/constant_strings.dart';
import 'package:app/src/helpers/helper_security_keys/helper_security_keys_bloc.dart';
import 'package:app/src/helpers/helper_security_keys/helper_security_keys_bloc_provider.dart';
import 'package:app/src/helpers/helper_security_keys/helper_security_keys_model.dart';
import 'package:app/src/platform/platform_page_route.dart';
import 'package:app/src/platform/platform_relative_size.dart';
import 'package:app/src/platform/platform_scaffold.dart';
import 'package:app/src/screens/screen_home.dart';
import 'package:app/src/screens/screen_keys_load.dart';
import 'package:app/src/ui/ui_security_backup/ui_security_backup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/cupertino/page_scaffold.dart';
import 'package:flutter/src/material/scaffold.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

class ScreenKeysSave extends PlatformScaffold {
  static final double _hPadding =
      ConstantSizes.hPadding * PlatformRelativeSize.safeBlockHorizontal;
  static final double _vMarginStart =
      15 * PlatformRelativeSize.safeBlockVertical;
  static final double _vMargin = 2.5 * PlatformRelativeSize.safeBlockVertical;
  static final double _fSizeTitle =
      10 * PlatformRelativeSize.safeBlockHorizontal;
  static final double _fSizeSubtitle =
      5 * PlatformRelativeSize.safeBlockHorizontal;
  static final double _fSizeLoad = 5 * PlatformRelativeSize.safeBlockHorizontal;
  static final double _fSizeSkip = 4 * PlatformRelativeSize.safeBlockHorizontal;
  static final Widget _toLoad = ScreenKeysLoad();
  static final Widget _toHome = ScreenHome();

  final HelperSecurityKeysModel _newModel;

  ScreenKeysSave(this._newModel);

  @override
  Scaffold androidScaffold(BuildContext context) {
    return Scaffold(body: _stack(context));
  }

  @override
  CupertinoPageScaffold iosScaffold(BuildContext context) {
    return CupertinoPageScaffold(child: _stack(context));
  }

  Widget _stack(BuildContext context) {
    return Stack(
      children: [
        _background(),
        LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: _foreground(context)));
        })
      ],
    );
  }

  Widget _background() {
    return Stack(
      children: [
        Container(
          color: ConstantColors.serenade,
        ),
        Container(
            child: Align(
                alignment: Alignment.topRight,
                child: Image(image: AssetImage('res/images/keys-blob.png')))),
      ],
    );
  }

  Widget _foreground(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: _hPadding),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _title(),
          _subtitle(),
          Container(
              margin: EdgeInsets.only(top: _vMargin),
              child: UISecurityBackup(_onBackupComplete, provided: _newModel)),
          _skipButton(context),
          _restoreButton(context, _toLoad)
        ]));
  }

  Widget _title() {
    return Container(
        margin: EdgeInsets.only(top: _vMarginStart),
        child: Align(
            alignment: Alignment.center,
            child: Text(ConstantStrings.keysTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Koara',
                    fontSize: _fSizeTitle,
                    fontWeight: FontWeight.bold,
                    color: ConstantColors.mardiGras))));
  }

  Widget _subtitle() {
    return Container(
        margin: EdgeInsets.only(top: _vMargin),
        child: Align(
            alignment: Alignment.center,
            child: Text(ConstantStrings.keysSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: _fSizeSubtitle,
                    fontWeight: FontWeight.w600,
                    color: ConstantColors.emperor))));
  }

  Widget _restoreButton(BuildContext context, Widget to) {
    return Container(
        margin: EdgeInsets.only(top: _vMargin, bottom: 3 * _vMargin),
        child: Align(
            alignment: Alignment.center,
            child: TextButton(
                onPressed: () {
                  Navigator.push(context, platformPageRoute(to));
                },
                child: Text(ConstantStrings.keysRestore,
                    style: TextStyle(
                        color: ConstantColors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: _fSizeLoad)))));
  }

  Widget _skipButton(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: _vMargin),
        child: Align(
            alignment: Alignment.topCenter,
            child: TextButton(
                onPressed: () {
                  _onBackupComplete(context);
                },
                child: Text(ConstantStrings.keysSkip,
                    style: TextStyle(
                        color: ConstantColors.boulder,
                        fontWeight: FontWeight.bold,
                        fontSize: _fSizeSkip)))));
  }

  Future<void> _onBackupComplete(BuildContext context) async {
    HelperSecurityKeysBloc securityKeysBloc =
        HelperSecurityKeysBlocProvider.of(context).bloc;
    await securityKeysBloc.save(_newModel);
    Navigator.pushAndRemoveUntil(
        context, platformPageRoute(_toHome), (Route<dynamic> route) => false);
  }
}
