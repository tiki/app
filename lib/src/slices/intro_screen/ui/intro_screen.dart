/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../intro_screen_service.dart';
import 'intro_screen_background_view.dart';
import 'intro_screen_foreground_view.dart';

class IntroScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var controller =
        Provider.of<IntroScreenService>(context, listen: false).controller;
    return Scaffold(
        body: Center(
            child: GestureDetector(
                child: Stack(
                    children: [
                      IntroScreenBackgroundView(),
                      IntroScreenForegroundView()
                    ]),
                onHorizontalDragEnd: (dragEndDetails) =>
                    controller.onHorizontalDrag(context, dragEndDetails)
            )
    ));
  }
}