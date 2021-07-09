/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:app/src/config/config_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';

class UserAccountModalViewHeader extends StatelessWidget {
  static const String _text = "Account";

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: Opacity(
                  opacity: 0.0,
                  child: Image(
                    alignment: Alignment.centerLeft,
                    image: AssetImage('res/images/icon-back.png'),
                    height: 12.sp,
                    fit: BoxFit.fitHeight,
                  ))),
          Text(_text,
              style: TextStyle(
                  color: ConfigColor.mardiGras,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.sp)),
          Expanded(
              child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Image(
                    alignment: Alignment.centerRight,
                    image: AssetImage('res/images/icon-x.png'),
                    height: 12.sp,
                    fit: BoxFit.fitHeight,
                  )))
        ]);
  }
}
