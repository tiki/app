/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../config/config_color.dart';
import '../../../widgets/link_account/link_account.dart';
import '../data_screen_service.dart';
import 'data_screen_view_score.dart';
import 'data_screen_view_soon.dart';

class DataScreenLayoutBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DataScreenService service = Provider.of<DataScreenService>(context);
    var isLinked = service.model.googleAccount != null;
    return GestureDetector(
        child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  children: [
                    DataScreenViewScore(
                        image: isLinked ? "data-score-happy" : "data-score-sad",
                        summary:
                            isLinked ? "All good!" : "Uh-oh. No data just yet!",
                        description: isLinked
                            ? "Your account is linked now. See what data Gmail holds by tapping on the button below."
                            : "Get started by adding a Gmail account",
                        color: isLinked ? ConfigColor.green : ConfigColor.blue),
                    Container(
                      margin: EdgeInsets.only(top: 2.h),
                      child: LinkAccount(
                        username: service.model.googleAccount?.email,
                        type: "Google",
                        linkedIcon: "account-soon-gmail",
                        unlinkedIcon: "google-icon",
                        onLink: () => service.controller.linkAccount("oauth0"),
                        //service.controller.linkGmail(context),
                        onUnlink: () => service.removeGoogleAccount(),
                        onSee: () => service.controller.openGmailCards(context),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 2.h),
                        child: DataScreenViewSoon())
                  ],
                ))));
  }
}
