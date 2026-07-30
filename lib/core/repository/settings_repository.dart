import 'package:kokotoba_flutter_app/core/model/kokotoba_settings.dart';

abstract interface class SettingsRepository {
  Future<KokotobaSettings> fetchSettings();
}
