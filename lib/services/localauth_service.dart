import 'dart:developer';

import 'package:local_auth/local_auth.dart';

class LocalAuth {
  final LocalAuthentication auth = LocalAuthentication();
  Future<bool> canAuthenticate() async {
    final bool isDeviceSupported = await auth.isDeviceSupported();
    final bool canCheckBiometrics = await auth.canCheckBiometrics;

    log('Is device supported: $isDeviceSupported');
    log('Can check biometrics: $canCheckBiometrics');

    return isDeviceSupported && canCheckBiometrics;
  }

  Future<bool> authenticate(String? textoAutenticacao) async {
    if (!await canAuthenticate()) {
      log("Autenticação não suportada ou biometria indisponível");
      return false;
    }

    return auth.authenticate(
      localizedReason: textoAutenticacao ?? "Autentique-se",
    );
  }
}

