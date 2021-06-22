/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:app/src/config/config_color.dart';
import 'package:app/src/utils/helper_image.dart';
import 'package:app/src/widgets/components/tiki_inputs/tiki_text_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TikiScreenViewLogout extends StatelessWidget {
  static const String _text = "Log out";

  @override
  Widget build(BuildContext context) {
    return TikiTextButton(
      _text,
      _logout,
      fontSize: 4,
      fontWeight: FontWeight.bold,
      color: ConfigColor.grenadier,
      trailing: Padding(
          padding: EdgeInsets.only(left: 16),
          child: HelperImage("icon-logout")),
    );
  }

  _logout(context) {

  }
}
