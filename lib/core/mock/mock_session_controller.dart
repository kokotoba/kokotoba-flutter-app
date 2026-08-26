import 'package:kokotoba_flutter_app/core/controller/session_controller.dart';
import 'package:kokotoba_flutter_app/core/model/conversation_session.dart';

class MockSessionController implements SessionController {
  MockSessionController();

  final List<ConversationSession> _sessions = [];
  var _nextId = 1;

  @override
  Future<ConversationSession> startOrResumeSession() async {
    final active = _sessions.where((session) => session.isActive);
    if (active.isNotEmpty) return active.last;

    final session = ConversationSession(
      id: 'mock-session-${_nextId++}',
      startedAt: DateTime.now(),
    );
    _sessions.add(session);
    return session;
  }

  @override
  Future<void> endSession(String sessionId) async {
    _replace(sessionId, (session) => session.copyWith(endedAt: DateTime.now()));
  }

  @override
  Future<void> recordUtterance(String sessionId, Utterance utterance) async {
    _replace(
      sessionId,
      (session) =>
          session.copyWith(utterances: [...session.utterances, utterance]),
    );
  }

  @override
  Future<List<ConversationSession>> fetchSessions() async {
    final sorted = [..._sessions]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return List.unmodifiable(sorted);
  }

  void _replace(
    String sessionId,
    ConversationSession Function(ConversationSession) update,
  ) {
    final index = _sessions.indexWhere((session) => session.id == sessionId);
    if (index == -1) {
      throw StateError('セッションが見つかりません: $sessionId');
    }
    _sessions[index] = update(_sessions[index]);
  }
}
