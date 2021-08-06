import 'package:app/src/config/config_color.dart';
import 'package:app/src/config/config_font.dart';
import 'package:app/src/utils/helper_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../decision_card_spam_service.dart';

class DecisionCardSpamViewHeader extends StatelessWidget {
  final GlobalKey shareKey;
  final String shareMessage;
  final DecisionCardSpamService service;

  DecisionCardSpamViewHeader(this.service, this.shareKey, this.shareMessage);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 3.w, right: 3.w, top: 1.h),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Expanded(
              child: Row(children: [
            HelperImage("gmail-round-logo", width: 5.5.w),
            Padding(padding: EdgeInsets.only(right: 2.w)),
            Text(
              "Your Gmail account",
              style: TextStyle(
                  fontFamily: ConfigFont.familyNunitoSans,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: ConfigColor.greyFive),
            )
          ])),
          Opacity(
              opacity: 0,
              child: GestureDetector(
                  onTap: () => service.controller
                      .shareCard(context, shareKey, shareMessage),
                  child:
                      Icon(Icons.share, color: ConfigColor.orange, size: 8.w)))
        ]));
  }
}
