/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:app/src/constants/constant_colors.dart';
import 'package:app/src/constants/constant_sizes.dart';
import 'package:app/src/constants/constant_strings.dart';
import 'package:app/src/screens/screen_keys_load.dart';
import 'package:app/src/utilities/platform_scaffold.dart';
import 'package:app/src/utilities/relative_size.dart';
import 'package:app/src/utilities/utility_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/cupertino/page_scaffold.dart';
import 'package:flutter/src/material/scaffold.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

class ScreenKeys extends PlatformScaffold {
  static final double _hPadding =
      ConstantSizes.hPadding * RelativeSize.safeBlockHorizontal;
  static final double _vMarginStart = 15 * RelativeSize.safeBlockVertical;
  static final double _vMargin = 2.5 * RelativeSize.safeBlockVertical;
  static final double _vMarginLoad = 8 * RelativeSize.safeBlockVertical;
  static final double _fSizeTitle = 10 * RelativeSize.safeBlockHorizontal;
  static final double _fSizeSubtitle = 5 * RelativeSize.safeBlockHorizontal;
  static final double _fSizeLoad = 5 * RelativeSize.safeBlockHorizontal;
  static final double _fSizeSkip = 4 * RelativeSize.safeBlockHorizontal;
  static final double _fSizeButton = 6 * RelativeSize.safeBlockHorizontal;
  static final double _heightButton = 8 * RelativeSize.safeBlockVertical;
  static final double _widthButton = 50 * RelativeSize.safeBlockHorizontal;
  static final Widget _toLoad = ScreenKeysLoad();
  static final Widget _toHome = ScreenKeysLoad();

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
      children: [_background(), _foreground(context)],
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
    return Row(children: [
      Expanded(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: _hPadding),
              child: Column(children: [
                _title(),
                _subtitle(),
                _saveButton(context),
                _skipButton(context, _toLoad),
                _restoreButton(context, _toHome)
              ])))
    ]);
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
    return Expanded(
        child: Container(
            margin: EdgeInsets.only(bottom: _vMarginLoad),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                    onPressed: () {
                      Navigator.push(context, platformPageRoute(to));
                    },
                    child: Text(ConstantStrings.keysRestore,
                        style: TextStyle(
                            color: ConstantColors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: _fSizeLoad))))));
  }

  Widget _skipButton(BuildContext context, Widget to) {
    return Expanded(
        child: Container(
            margin: EdgeInsets.only(top: _vMargin),
            child: Align(
                alignment: Alignment.topCenter,
                child: TextButton(
                    onPressed: () {
                      Navigator.push(context, platformPageRoute(to));
                    },
                    child: Text(ConstantStrings.keysSkip,
                        style: TextStyle(
                            color: ConstantColors.boulder,
                            fontWeight: FontWeight.bold,
                            fontSize: _fSizeSkip))))));
  }

  //TODO move to BLOC
  Widget _saveButton(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: _vMargin),
        child: Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(_vMargin * 2))),
                  primary: ConstantColors.mardiGras),
              child: Container(
                  width: _widthButton,
                  height: _heightButton,
                  child: Center(
                      child: Text(ConstantStrings.keysSave,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: _fSizeButton,
                              letterSpacing:
                                  0.05 * RelativeSize.safeBlockHorizontal)))),
              onPressed: () {},
            )));
  }
}
