import 'package:app/src/slices/decision_card_spam/decision_card_spam_service.dart';
import 'package:app/src/slices/decision_card_spam/model/decision_card_spam_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sizer/sizer.dart';

import 'decision_card_spam_view_company.dart';
import 'decision_card_spam_view_data_info_row.dart';
import 'decision_card_spam_view_frequency.dart';
import 'decision_card_spam_view_header.dart';
import 'decision_card_spam_view_security.dart';
import 'decision_card_spam_view_separator.dart';

class DecisionCardSpamLayoutContent extends StatelessWidget {
  final GlobalKey shareKey;

  final DecisionCardSpamModel cardSpamModel;
  final DecisionCardSpamService service;

  DecisionCardSpamLayoutContent(
      this.shareKey, this.service, this.cardSpamModel);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          DecisionCardSpamViewHeader(this.service, this.shareKey, "mensagem"),
          Padding(
              padding: EdgeInsets.only(left: 3.w, right: 3.w, top: 2.h),
              child: DecisionCardSpamViewCompany(
                  logo: this.cardSpamModel.logoUrl,
                  name: this.cardSpamModel.companyName,
                  email: this.cardSpamModel.senderEmail)),
          Expanded(
              child: Container(
                  margin: EdgeInsets.only(
                      left: 5.w, right: 5.w, top: 2.h, bottom: 2.5.h),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.h),
                      color: Color(0xFFF8F8F8)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: 2.8.h),
                            child: DecisionCardSpamViewFrequency(
                                this.cardSpamModel.frequency.toString(),
                                this.cardSpamModel.category.toString())),
                        Padding(
                            padding: EdgeInsets.only(
                                top: 2.h, left: 7.w, right: 7.w),
                            child: DecisionCardSpamViewSeparator()),
                        Padding(
                            padding: EdgeInsets.only(top: 1.h),
                            child: DecisionCardSpamViewDataInfoRow(
                                this.cardSpamModel.sinceYear,
                                this.cardSpamModel.totalEmails,
                                this.cardSpamModel.openRate)),
                        Padding(
                            padding: EdgeInsets.only(top: 3.5.h),
                            child: DecisionCardSpamViewSecurity(
                              starRates: this.cardSpamModel.securityScore,
                              sensitivity: this.cardSpamModel.sensitivityScore,
                              hacking: this.cardSpamModel.hackingScore,
                            ))
                      ])))
        ]));
  }
}
