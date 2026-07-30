import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/ui/cards/cards_screen.dart';
import 'package:kokotoba_flutter_app/ui/cards/confirm_screen.dart';
import 'package:kokotoba_flutter_app/ui/cards/edit_screen.dart';
import 'package:kokotoba_flutter_app/ui/conversation/conversation_screen.dart';
import 'package:kokotoba_flutter_app/ui/conversation/listening_screen.dart';
import 'package:kokotoba_flutter_app/ui/conversation/manual_input_screen.dart';
import 'package:kokotoba_flutter_app/ui/history/history_screen.dart';
import 'package:kokotoba_flutter_app/ui/home/home_screen.dart';
import 'package:kokotoba_flutter_app/ui/onboarding/onboarding_screen.dart';
import 'package:kokotoba_flutter_app/ui/settings/settings_screen.dart';
import 'package:kokotoba_flutter_app/core/repository/kokotoba_repositories.dart';

enum AppScreen {
  home,
  listening,
  conversation,
  cards,
  history,
  settings,
  confirm,
  edit,
  manual,
  onboarding,
}

class KokotobaApp extends StatefulWidget {
  const KokotobaApp({
    super.key,
    this.repositories = const KokotobaRepositories.mock(),
  });

  final KokotobaRepositories repositories;

  @override
  State<KokotobaApp> createState() => _KokotobaAppState();
}

class _KokotobaAppState extends State<KokotobaApp> {
  AppScreen screen = AppScreen.home;
  String selectedPhrase = '昨日から頭が痛いです';

  static const destinations = [
    (AppScreen.home, 'ホーム', Icons.home_outlined, Icons.home),
    (AppScreen.conversation, '会話', Icons.mic_none, Icons.mic),
    (AppScreen.cards, 'カード', Icons.copy_outlined, Icons.copy),
    (AppScreen.history, '履歴', Icons.history, Icons.history),
    (AppScreen.settings, '設定', Icons.settings_outlined, Icons.settings),
  ];

  bool get isMainScreen =>
      destinations.any((destination) => destination.$1 == screen);

  void go(AppScreen next) => setState(() => screen = next);

  void handleBack() {
    if (isMainScreen) {
      if (screen != AppScreen.home) go(AppScreen.home);
      return;
    }
    if (screen == AppScreen.edit) {
      go(AppScreen.confirm);
    } else if (screen == AppScreen.confirm) {
      go(AppScreen.conversation);
    } else {
      go(AppScreen.home);
    }
  }

  Widget get currentScreen {
    return switch (screen) {
      AppScreen.home => HomeScreen(
        startConversation: () => go(AppScreen.listening),
        manualInput: () => go(AppScreen.manual),
        openCards: () => go(AppScreen.cards),
        openOnboarding: () => go(AppScreen.onboarding),
      ),
      AppScreen.listening => ListeningScreen(
        onBack: () => go(AppScreen.home),
        showExample: () => go(AppScreen.conversation),
      ),
      AppScreen.conversation => ConversationScreen(
        confirm: () => go(AppScreen.confirm),
        manualInput: () => go(AppScreen.manual),
      ),
      AppScreen.cards => CardsScreen(
        repository: widget.repositories.registeredCardRepository,
      ),
      AppScreen.history => HistoryScreen(
        repository: widget.repositories.conversationHistoryRepository,
      ),
      AppScreen.settings => SettingsScreen(
        repository: widget.repositories.settingsRepository,
      ),
      AppScreen.confirm => ConfirmScreen(
        text: selectedPhrase,
        onBack: () => go(AppScreen.conversation),
        onEdit: () => go(AppScreen.edit),
      ),
      AppScreen.edit => EditScreen(
        initialText: selectedPhrase,
        onCancel: () => go(AppScreen.confirm),
        onSave: (value) => setState(() {
          selectedPhrase = value;
          screen = AppScreen.confirm;
        }),
      ),
      AppScreen.manual => ManualInputScreen(onBack: () => go(AppScreen.home)),
      AppScreen.onboarding => OnboardingScreen(
        onBack: () => go(AppScreen.home),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: screen == AppScreen.home,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) handleBack();
      },
      child: Scaffold(
        body: currentScreen,
        bottomNavigationBar: isMainScreen
            ? NavigationBar(
                backgroundColor: Colors.white,
                selectedIndex: destinations.indexWhere(
                  (destination) => destination.$1 == screen,
                ),
                onDestinationSelected: (index) => go(destinations[index].$1),
                destinations: [
                  for (final destination in destinations)
                    NavigationDestination(
                      icon: Icon(destination.$3),
                      selectedIcon: Icon(destination.$4),
                      label: destination.$2,
                    ),
                ],
              )
            : null,
      ),
    );
  }
}
