/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:app/src/config/config_color.dart';
import 'package:app/src/features/keys/keys_restore_screen/bloc/keys_restore_screen_bloc.dart';
import 'package:app/src/features/keys/keys_restore_screen/widgets/keys_restore_screen_back.dart';
import 'package:app/src/features/keys/keys_restore_screen/widgets/keys_restore_screen_input.dart';
import 'package:app/src/features/keys/keys_restore_screen/widgets/keys_restore_screen_scan.dart';
import 'package:app/src/features/keys/keys_restore_screen/widgets/keys_restore_screen_submit.dart';
import 'package:app/src/features/keys/keys_restore_screen/widgets/keys_restore_screen_subtitle.dart';
import 'package:app/src/utils/helper/helper_image.dart';
import 'package:app/src/utils/platform/platform_relative_size.dart';
import 'package:app/src/widgets/screens/tiki_background.dart';
import 'package:app/src/widgets/screens/tiki_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/keys_restore_screen_divider.dart';
import 'widgets/keys_restore_screen_title.dart';

class KeysRestoreScreen extends StatelessWidget {
  static final double _marginTopTitle = 4 * PlatformRelativeSize.blockVertical;
  static final double _marginTopSubtitle =
      2.5 * PlatformRelativeSize.blockVertical;
  static final double _marginTopScan = 2.5 * PlatformRelativeSize.blockVertical;
  static final double _marginHorizontalInput =
      7 * PlatformRelativeSize.blockHorizontal;
  static final double _marginVerticalDivider =
      5 * PlatformRelativeSize.blockVertical;
  static final double _marginTopSubmit = 5 * PlatformRelativeSize.blockVertical;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => KeysRestoreScreenBloc.provide(context),
        child: TikiScaffold(
            background: _background() as TikiBackground?,
            foregroundChildren: _foreground(context)));
  }

  Widget _background() {
    return TikiBackground(
      backgroundColor: ConfigColor.serenade,
      topRight: HelperImage("keys-blob"),
    );
  }

  List<Widget> _foreground(BuildContext context) {
    return [
      Container(
        alignment: Alignment.topLeft,
        child: KeysRestoreScreenBack(),
      ),
      Container(
          margin: EdgeInsets.only(top: _marginTopTitle),
          alignment: Alignment.center,
          child: KeysRestoreScreenTitle()),
      Container(
          margin: EdgeInsets.only(top: _marginTopSubtitle),
          alignment: Alignment.center,
          child: KeysRestoreScreenSubtitle()),
      Container(
          margin: EdgeInsets.symmetric(horizontal: _marginHorizontalInput),
          child: Column(children: [
            Container(
              margin: EdgeInsets.only(top: _marginTopScan),
              alignment: Alignment.center,
              child: KeysRestoreScreenScan(),
            ),
            Container(
                margin: EdgeInsets.symmetric(vertical: _marginVerticalDivider),
                child: KeysRestoreScreenDivider()),
            Container(child: KeysRestoreScreenInput()),
            Container(
                margin: EdgeInsets.only(top: _marginTopSubmit),
                child: KeysRestoreScreenSubmit())
          ]))
    ];
  }
}