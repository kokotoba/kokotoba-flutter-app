import 'package:kokotoba_flutter_app/core/model/kokotoba_settings.dart';

abstract interface class SettingsController {
  Future<KokotobaSettings> fetchSettings();

  Future<KokotobaSettings> updateSettings(KokotobaSettingsUpdate update);
}
