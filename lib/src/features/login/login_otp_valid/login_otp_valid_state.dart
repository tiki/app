/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

part of 'login_otp_valid_cubit.dart';

abstract class LoginOtpValidState extends Equatable {
  const LoginOtpValidState();

  @override
  List<Object> get props => [];
}

class LoginOtpValidInitial extends LoginOtpValidState {
  const LoginOtpValidInitial() : super();
}

class LoginOtpValidInProgress extends LoginOtpValidState {
  const LoginOtpValidInProgress() : super();
}

class LoginOtpValidSuccess extends LoginOtpValidState {
  const LoginOtpValidSuccess() : super();
}

class LoginOtpValidFailure extends LoginOtpValidState {
  const LoginOtpValidFailure() : super();
}
