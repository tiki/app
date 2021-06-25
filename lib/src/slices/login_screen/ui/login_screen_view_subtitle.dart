import 'package:app/src/config/config_color.dart';
import 'package:app/src/slices/login_screen/login_screen_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class LoginScreenViewSubtitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var service = Provider.of<LoginScreenService>(context);
    return Text(service.presenter.subtitle,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: service.presenter.emailSubtitleFontSize.sp,
            fontWeight: FontWeight.w600,
            color: ConfigColor.emperor));
  }
}
