/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:app/src/config/config_color.dart';
import 'package:app/src/config/config_string.dart';
import 'package:app/src/utils/platform/platform_relative_size.dart';
import 'package:flutter/cupertino.dart';

class KeysNewScreenSaveSubtitle extends StatelessWidget {
  static final double _fontSize = 5 * PlatformRelativeSize.blockHorizontal;

  @override
  Widget build(BuildContext context) {
    return Text(ConfigString.keysNew.saveSubtitle,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            color: ConfigColor.emperor));
  }
}
