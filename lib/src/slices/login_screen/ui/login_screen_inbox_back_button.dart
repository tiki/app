/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:app/src/config/config_color.dart';
import 'package:app/src/slices/login_screen/login_screen_service.dart';
import 'package:app/src/utils/helper_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreenInboxBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var service = Provider.of<LoginScreenService>(context);
    return TextButton(
      onPressed: () => Provider.of<LoginScreenService>(context, listen: false)
          .controller
          .back(context),
      child: Row(children: [
        Container(
          child: HelperImage('back-arrow'),
          margin:
              EdgeInsets.only(right: service.presenter.backMarginRightArrow),
        ),
        Text(service.presenter.backText,
            style: TextStyle(
                color: ConfigColor.orange,
                fontWeight: FontWeight.w800,
                fontSize: service.presenter.backFontSize))
      ]),
    );
  }
}
