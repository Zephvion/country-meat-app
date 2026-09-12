import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentAssets {
  PaymentAssets._();

  static const String gpay = 'assets/images/payments/gpay.svg';
  static const String phonepe = 'assets/images/payments/phonepe.svg';
  static const String amazonPay = 'assets/images/payments/amazon_pay.svg';
  static const String whatsapp = 'assets/images/payments/whatsapp.svg';
  static const String paytm = 'assets/images/payments/paytm.svg';
  static const String upi = 'assets/images/payments/upi.svg';
  static const String slice = 'assets/images/payments/slice.svg';

  /// Renders a standardized, visually balanced payment logo with exact aspect ratio.
  static Widget buildLogo(String key, {double height = 24.0}) {
    switch (key) {
      case 'gpay':
        return SvgPicture.asset(gpay, height: height, fit: BoxFit.contain);
      case 'phonepe':
        return SvgPicture.asset(phonepe, height: height, fit: BoxFit.contain);
      case 'amazon':
      case 'amazon_pay':
        return SvgPicture.asset(amazonPay, height: height, fit: BoxFit.contain);
      case 'whatsapp':
        return SvgPicture.asset(whatsapp, height: height, fit: BoxFit.contain);
      case 'paytm':
        return SvgPicture.asset(paytm, height: height, fit: BoxFit.contain);
      case 'upi':
        return SvgPicture.asset(upi, height: height, fit: BoxFit.contain);
      case 'slice':
        return SvgPicture.asset(slice, height: height, fit: BoxFit.contain);
      default:
        return Icon(Icons.account_balance_wallet_outlined, size: height);
    }
  }
}
