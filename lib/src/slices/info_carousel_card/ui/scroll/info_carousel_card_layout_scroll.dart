/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:app/src/config/config_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../info_carousel_card_service.dart';
import 'info_carousel_card_view_scroll_body_explain.dart';
import 'info_carousel_card_view_scroll_body_should_know.dart';
import 'info_carousel_card_view_scroll_body_they_say.dart';
import 'info_carousel_card_view_scroll_cta_button.dart';
import 'info_carousel_card_view_scroll_cta_explain.dart';
import 'info_carousel_card_view_scroll_cta_heading.dart';
import 'info_carousel_card_view_scroll_header.dart';

class InfoCarouselCardLayoutScroll extends StatelessWidget {
  final Animation<double> _animationValue;

  InfoCarouselCardLayoutScroll(this._animationValue);

  @override
  Widget build(BuildContext context) {
    var service = Provider.of<InfoCarouselCardService>(context);
    return Container(
        color: ConfigColor.alto,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  color: ConfigColor.white,
                  padding: EdgeInsets.only(left: 4.w, top: 1.h, right: 4.w),
                  child: InfoCarouselCardViewScrollHeader(_animationValue)),
              Container(
                  color: ConfigColor.mardiGras,
                  child: Column(children: [
                    Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 3.h),
                        child: InfoCarouselCardViewScrollBodyExplain()),
                    InfoCarouselCardViewScrollBodyTheySay(),
                    InfoCarouselCardViewScrollBodyShouldKnow(),
                  ])),
              Container(
                  color: ConfigColor.alto,
                  padding: EdgeInsets.only(left: 4.w, top: 3.h, right: 4.w),
                  child: Column(children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        child: InfoCarouselCardViewScrollCtaHeading()),
                    Container(
                        padding: EdgeInsets.only(top: 2.h),
                        child: InfoCarouselCardViewScrollCtaExplain()),
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        child: InfoCarouselCardViewScrollCtaButton()),
                  ])),
            ],
          ),
        ));
  }
}