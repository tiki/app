/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:app/src/slices/keys_create_screen/keys_create_screen_service.dart';
import 'package:app/src/slices/keys_save_screen/keys_save_screen_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'keys_create_screen_layout_background.dart';
import 'keys_create_screen_layout_foreground.dart';

class KeysCreateScreenLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var service = Provider.of<KeysCreateScreenService>(context);
    return Scaffold(body: Center(child: _widget(service)));
  }

  Widget _widget(KeysCreateScreenService service) {
    if (service.model.isComplete)
      return KeysSaveScreenService().getUI();
    else {
      return Stack(children: [
        KeysCreateScreenLayoutBackground(),
        KeysCreateScreenLayoutForeground()
      ]);
    }
  }
}