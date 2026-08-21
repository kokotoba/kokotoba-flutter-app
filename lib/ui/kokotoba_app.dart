import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/auth/auth_service.dart';
import 'package:kokotoba_flutter_app/core/controller/kokotoba_controllers.dart';
import 'package:kokotoba_flutter_app/ui/conversation/conversation_screen.dart';
import 'package:kokotoba_flutter_app/ui/cards/cards_screen.dart';
import 'package:kokotoba_flutter_app/ui/history/history_screen.dart';
import 'package:kokotoba_flutter_app/ui/home/home_screen.dart';
import 'package:kokotoba_flutter_app/ui/settings/settings_screen.dart';

enum MainTab { home, conversation, cards, history, settings }

class KokotobaApp extends StatefulWidget {
  const KokotobaApp({
    super.key,
    required this.controllers,
    this.authUser,
    this.onSignOut,
    this.onSendEmailVerification,
  });

  final KokotobaControllers controllers;
  final AuthUser? authUser;
  final Future<void> Function()? onSignOut;
  final Future<void> Function()? onSendEmailVerification;

  @override
  State<KokotobaApp> createState() => _KokotobaAppState();
}

class _KokotobaAppState extends State<KokotobaApp> {
  MainTab selectedTab = MainTab.home;
  var conversationEntry = ConversationEntry.suggestions;

  static const destinations = [
    (MainTab.home, 'ホーム', Icons.home_outlined, Icons.home),
    (MainTab.conversation, '会話', Icons.mic_none, Icons.mic),
    (MainTab.cards, 'カード', Icons.copy_outlined, Icons.copy),
    (MainTab.history, '履歴', Icons.history, Icons.history),
    (MainTab.settings, '設定', Icons.settings_outlined, Icons.settings),
  ];

  void selectTab(MainTab tab) {
    setState(() {
      selectedTab = tab;
      if (tab == MainTab.conversation) {
        conversationEntry = ConversationEntry.suggestions;
      }
    });
  }

  void openConversation(ConversationEntry entry) {
    setState(() {
      selectedTab = MainTab.conversation;
      conversationEntry = entry;
    });
  }

  Widget get currentScreen {
    return switch (selectedTab) {
      MainTab.home => HomeScreen(
        startConversation: () => openConversation(ConversationEntry.listening),
        manualInput: () => openConversation(ConversationEntry.manual),
        openCards: () => selectTab(MainTab.cards),
      ),
      MainTab.conversation => ConversationScreen(
        key: ValueKey(conversationEntry),
        initialEntry: conversationEntry,
        controller: widget.controllers.conversationController,
      ),
      MainTab.cards => CardsScreen(
        controller: widget.controllers.registeredCardController,
      ),
      MainTab.history => HistoryScreen(
        controller: widget.controllers.conversationHistoryController,
      ),
      MainTab.settings => SettingsScreen(
        controller: widget.controllers.settingsController,
        authUser: widget.authUser,
        onSignOut: widget.onSignOut,
        onSendEmailVerification: widget.onSendEmailVerification,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: selectedTab == MainTab.home,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) selectTab(MainTab.home);
      },
      child: Scaffold(
        body: currentScreen,
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.white,
          selectedIndex: destinations.indexWhere(
            (destination) => destination.$1 == selectedTab,
          ),
          onDestinationSelected: (index) => selectTab(destinations[index].$1),
          destinations: [
            for (final destination in destinations)
              NavigationDestination(
                icon: Icon(destination.$3),
                selectedIcon: Icon(destination.$4),
                label: destination.$2,
              ),
          ],
        ),
      ),
    );
  }
}
