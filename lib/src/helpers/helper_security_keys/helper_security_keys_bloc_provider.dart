/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:app/src/helpers/helper_dynamic_link/helper_dynamic_link_bloc.dart';
import 'package:app/src/helpers/helper_security_keys/helper_security_keys_bloc.dart';
import 'package:app/src/repos/repo_blockchain_address/repo_blockchain_address_bloc.dart';
import 'package:app/src/repos/repo_ss_security_keys/repo_ss_security_keys_bloc.dart';
import 'package:app/src/repos/repo_ss_user/repo_ss_user_bloc.dart';
import 'package:flutter/cupertino.dart';

class HelperSecurityKeysBlocProvider extends InheritedWidget {
  final HelperSecurityKeysBloc _bloc;

  HelperSecurityKeysBlocProvider(
      RepoSSUserBloc ssUserBloc,
      RepoSSSecurityKeysBloc ssSecurityKeysBloc,
      RepoBlockchainAddressBloc repoBlockchainAddressBloc,
      HelperDynamicLinkBloc helperDynamicLinkBloc,
      {Key key,
      Widget child})
      : _bloc = HelperSecurityKeysBloc(ssUserBloc, ssSecurityKeysBloc,
            repoBlockchainAddressBloc, helperDynamicLinkBloc),
        super(key: key, child: child);

  HelperSecurityKeysBloc get bloc => _bloc;

  static HelperSecurityKeysBlocProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HelperSecurityKeysBlocProvider>();
  }

  @override
  bool updateShouldNotify(HelperSecurityKeysBlocProvider oldWidget) {
    return false;
  }
}
