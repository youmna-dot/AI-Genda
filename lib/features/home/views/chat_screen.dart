// lib/features/home/views/chat_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/controllers/auth_controller.dart';

// ══════════════════════════════════════════════════════
// CHAT SCREEN
// ══════════════════════════════════════════════════════
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isTyping = false; // AI typing indicator
  int _activeSessionIndex = -1; // -1 = new empty chat

  // ── Chat sessions (history) ──
  final List<_ChatSession> _sessions = [
    _ChatSession(title: 'Platform Marketplace 101',
        messages: [], date: DateTime.now().subtract(const Duration(days: 1))),
    _ChatSession(title: 'Give me a proposal for company...',
        messages: [], date: DateTime.now().subtract(const Duration(days: 1))),
    _ChatSession(title: 'Can you write a short paragraph f...',
        messages: [], date: DateTime.now().subtract(const Duration(days: 1))),
    _ChatSession(title: 'Research about ui ux',
        messages: [], date: DateTime.now().subtract(const Duration(days: 1))),
    _ChatSession(title: 'Platform Marketplace 101',
        messages: [], date: DateTime.now().subtract(const Duration(days: 7))),
    _ChatSession(title: 'Give me a proposal for company...',
        messages: [], date: DateTime.now().subtract(const Duration(days: 7))),
    _ChatSession(title: 'Platform Marketplace 101',
        messages: [], date: DateTime.now().subtract(const Duration(days: 30))),
    _ChatSession(title: 'Give me a proposal for company...',
        messages: [], date: DateTime.now().subtract(const Duration(days: 30))),
  ];

  // ── Current messages ──
  List<_ChatMessage> _messages = [];

  // ── Suggestion chips ──
  final List<_Suggestion> _suggestions = const [
    _Suggestion(title: 'Come up with concepts',
        subtitle: 'for a retro style arcade game'),
    _Suggestion(title: 'Explain why popcorn pops',
        subtitle: 'to a kid who loves to watch in the microwave'),
    _Suggestion(title: 'Plan a trip',
        subtitle: 'to see the northern lights in norway'),
    _Suggestion(title: 'Give me ideas',
        subtitle: "for what to do with my kid's art"),
    _Suggestion(title: 'Help me write',
        subtitle: 'a professional email to my manager'),
    _Suggestion(title: 'Summarize this topic',
        subtitle: 'artificial intelligence in 2025'),
  ];

  // ── Mock AI responses ──
  final List<String> _mockResponses = [
    "That's a great question! Let me think about this...\n\nHere are some ideas to get you started:\n• Start with a clear outline\n• Research relevant examples\n• Focus on the key message\n\nWould you like me to elaborate on any of these?",
    "Sure! I'd be happy to help with that. 😊\n\nHere's what I suggest:\n1. Define your goals clearly\n2. Break it into smaller steps\n3. Track your progress\n\nLet me know if you need more details!",
    "Great idea! Here's a quick overview:\n\nThis approach works best when you combine creativity with structure. Think of it as building blocks — start simple, then add complexity.\n\nAnything specific you'd like to explore?",
    "Absolutely! I can help with that.\n\nThe key things to consider are:\n• Your target audience\n• The main goal\n• Available resources\n\nWant me to dive deeper into any of these areas?",
    "Interesting! Let me share some thoughts...\n\nThe best approach here would be to start with research, then move to planning, and finally execution. Each phase builds on the previous one.\n\nShall we start with step one?",
  ];

  int _mockIndex = 0;

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _msgCtrl.clear();
    _focusNode.unfocus();
    HapticFeedback.lightImpact();

    final userMsg = _ChatMessage(
      text: text.trim(),
      isUser: true,
      time: TimeOfDay.now(),
    );

    // If new chat, create session
    if (_activeSessionIndex == -1 && _messages.isEmpty) {
      final newSession = _ChatSession(
        title: text.length > 40
            ? '${text.substring(0, 40)}...'
            : text,
        messages: [],
        date: DateTime.now(),
      );
      setState(() {
        _sessions.insert(0, newSession);
        _activeSessionIndex = 0;
      });
    }

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulate AI thinking delay
    await Future.delayed(
        Duration(milliseconds: 800 + math.Random().nextInt(600)));

    if (!mounted) return;

    final aiResponse = _mockResponses[_mockIndex % _mockResponses.length];
    _mockIndex++;

    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage(
        text: aiResponse,
        isUser: false,
        time: TimeOfDay.now(),
      ));
    });
    _scrollToBottom();
  }

  void _startNewChat() {
    setState(() {
      _messages = [];
      _activeSessionIndex = -1;
    });
    Navigator.of(context).pop(); // close drawer if open
  }

  void _loadSession(int index) {
    setState(() {
      _activeSessionIndex = index;
      _messages = [];
    });
    Navigator.of(context).pop();
  }

  String get _displayName {
    final full = AuthController.currentUserName ?? 'there';
    return full.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F3FF),
      drawer: _ChatDrawer(
        sessions: _sessions,
        activeIndex: _activeSessionIndex,
        onNewChat: _startNewChat,
        onSelectSession: _loadSession,
        userName: AuthController.currentUserName ?? 'User',
        userEmail: AuthController.currentUserEmail ?? '',
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : _buildMessageList(),
            ),
            if (_isTyping) _buildTypingIndicator(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR ──
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom: BorderSide(color: Color(0xFFF0EEF8), width: 1)),
      ),
      child: Row(
        children: [
          // Menu / drawer button
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                    color: const Color(0xFFE8E4F5), width: 1.2),
              ),
              child: const Icon(Icons.menu_rounded,
                  color: Color(0xFF7C5CBF), size: 20),
            ),
          ),
          const SizedBox(width: 12),
          // New Chat button
          GestureDetector(
            onTap: _startNewChat,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                    color: const Color(0xFFE8E4F5), width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_rounded,
                      color: Color(0xFF7C5CBF), size: 16),
                  const SizedBox(width: 5),
                  Text('New Chat',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7C5CBF),
                      )),
                ],
              ),
            ),
          ),
          const Spacer(),
          // AI label
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const Icon(Icons.smart_toy_rounded,
                    color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text('AIGENDA AI',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── EMPTY STATE (robot + suggestions) ──
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          // Robot illustration
          _RobotIllustration(),
          const SizedBox(height: 8),
          Text(
            'Hi, $_displayName! 👋',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E0F5C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'What can I help you with today?',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF8A84A3),
            ),
          ),
          const SizedBox(height: 24),
          // Suggestion grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.0,
            ),
            itemCount: _suggestions.length,
            itemBuilder: (ctx, i) => _SuggestionChip(
              suggestion: _suggestions[i],
              onTap: () => _sendMessage(
                  '${_suggestions[i].title} ${_suggestions[i].subtitle}'),
            ),
          ),
        ],
      ),
    );
  }

  // ── MESSAGE LIST ──
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      physics: const BouncingScrollPhysics(),
      itemCount: _messages.length,
      itemBuilder: (ctx, i) => _MessageBubble(message: _messages[i]),
    );
  }

  // ── TYPING INDICATOR ──
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C3FC8).withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  // ── INPUT BAR ──
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C3FC8).withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                    color: const Color(0xFFE8E4F5), width: 1.2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      focusNode: _focusNode,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF1E0F5C)),
                      decoration: InputDecoration(
                        hintText: 'Type your message here...',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFFBBB8CC)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onSubmitted: _sendMessage,
                      textInputAction: TextInputAction.send,
                      maxLines: null,
                    ),
                  ),
                  // Mic button
                  GestureDetector(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: Icon(
                      Icons.mic_rounded,
                      color: const Color(0xFF8A84A3),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          GestureDetector(
            onTap: () => _sendMessage(_msgCtrl.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46, height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C3FC8).withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// CHAT DRAWER (history sidebar)
// ══════════════════════════════════════════════════════
class _ChatDrawer extends StatelessWidget {
  final List<_ChatSession> sessions;
  final int activeIndex;
  final VoidCallback onNewChat;
  final ValueChanged<int> onSelectSession;
  final String userName;
  final String userEmail;

  const _ChatDrawer({
    required this.sessions,
    required this.activeIndex,
    required this.onNewChat,
    required this.onSelectSession,
    required this.userName,
    required this.userEmail,
  });

  String _groupLabel(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff < 2) return 'YESTERDAY';
    if (diff < 8) return 'LAST WEEK';
    return 'LAST MONTH';
  }

  @override
  Widget build(BuildContext context) {
    // Group sessions
    final Map<String, List<MapEntry<int, _ChatSession>>> grouped = {};
    for (int i = 0; i < sessions.length; i++) {
      final label = _groupLabel(sessions[i].date);
      grouped.putIfAbsent(label, () => []);
      grouped[label]!.add(MapEntry(i, sessions[i]));
    }
    final order = ['YESTERDAY', 'LAST WEEK', 'LAST MONTH'];

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFF4A2D8A), Color(0xFF7C5CBF)],
                    ).createShader(b),
                    child: Text('AIGENDA',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 3,
                        )),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF8A84A3), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // New Chat button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: onNewChat,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C3FC8).withOpacity(0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text('New Chat',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Sessions list
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final group in order)
                    if (grouped.containsKey(group)) ...[
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 8, top: 4),
                        child: Text(group,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF7C5CBF),
                              letterSpacing: 0.8,
                            )),
                      ),
                      for (final entry in grouped[group]!)
                        _SessionTile(
                          session: entry.value,
                          isActive: entry.key == activeIndex,
                          onTap: () => onSelectSession(entry.key),
                        ),
                      const SizedBox(height: 8),
                    ],
                ],
              ),
            ),
            // Divider
            Container(height: 1, color: const Color(0xFFF0EEF8)),
            // User profile at bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty
                            ? userName[0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E0F5C),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(userEmail,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF8A84A3),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// SESSION TILE
// ══════════════════════════════════════════════════════
class _SessionTile extends StatelessWidget {
  final _ChatSession session;
  final bool isActive;
  final VoidCallback onTap;
  const _SessionTile(
      {required this.session,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFEDE6FF)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 15,
              color: isActive
                  ? const Color(0xFF7C5CBF)
                  : const Color(0xFF8A84A3),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                session.title,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: isActive
                      ? const Color(0xFF1E0F5C)
                      : const Color(0xFF5A5480),
                  fontWeight: isActive
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// ROBOT ILLUSTRATION (pure Flutter, no assets needed)
// ══════════════════════════════════════════════════════
class _RobotIllustration extends StatefulWidget {
  @override
  State<_RobotIllustration> createState() => _RobotIllustrationState();
}

class _RobotIllustrationState extends State<_RobotIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _float = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _float.value),
        child: SizedBox(
          height: 160,
          child: CustomPaint(
            painter: _RobotPainter(),
            size: const Size(160, 160),
          ),
        ),
      ),
    );
  }
}

class _RobotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    // Body glow
    paint.color = const Color(0xFF7C5CBF).withOpacity(0.08);
    canvas.drawCircle(Offset(cx, size.height * 0.55), 65, paint);

    // Body
    paint.color = const Color(0xFFEDE6FF);
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx, size.height * 0.62),
          width: 90, height: 70),
      const Radius.circular(20),
    );
    canvas.drawRRect(bodyRect, paint);

    // Head
    paint.color = Colors.white;
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx, size.height * 0.30),
          width: 76, height: 62),
      const Radius.circular(18),
    );
    canvas.drawRRect(headRect, paint);

    // Head border
    paint
      ..color = const Color(0xFFE8E4F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(headRect, paint);
    paint.style = PaintingStyle.fill;

    // Eyes
    paint.color = const Color(0xFF3ECFCF).withOpacity(0.9);
    canvas.drawCircle(Offset(cx - 14, size.height * 0.285), 8, paint);
    canvas.drawCircle(Offset(cx + 14, size.height * 0.285), 8, paint);

    // Eye shine
    paint.color = Colors.white.withOpacity(0.6);
    canvas.drawCircle(Offset(cx - 12, size.height * 0.27), 3, paint);
    canvas.drawCircle(Offset(cx + 16, size.height * 0.27), 3, paint);

    // Smile
    paint
      ..color = const Color(0xFF7C5CBF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final smilePath = Path();
    smilePath.moveTo(cx - 10, size.height * 0.335);
    smilePath.quadraticBezierTo(
        cx, size.height * 0.358, cx + 10, size.height * 0.335);
    canvas.drawPath(smilePath, paint);
    paint.style = PaintingStyle.fill;

    // Antenna
    paint.color = const Color(0xFFAB8EE0);
    canvas.drawRect(
        Rect.fromLTWH(cx - 1.5, size.height * 0.06, 3, 18), paint);
    paint.color = const Color(0xFF7C5CBF);
    canvas.drawCircle(Offset(cx, size.height * 0.06), 5, paint);

    // Arms
    paint.color = const Color(0xFFD8CEF0);
    final leftArm = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx - 58, size.height * 0.60),
          width: 16, height: 40),
      const Radius.circular(8),
    );
    final rightArm = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx + 58, size.height * 0.60),
          width: 16, height: 40),
      const Radius.circular(8),
    );
    canvas.drawRRect(leftArm, paint);
    canvas.drawRRect(rightArm, paint);

    // Chest orb
    paint.color = const Color(0xFF3ECFCF).withOpacity(0.25);
    canvas.drawCircle(Offset(cx, size.height * 0.62), 14, paint);
    paint.color = const Color(0xFF3ECFCF).withOpacity(0.6);
    canvas.drawCircle(Offset(cx, size.height * 0.62), 8, paint);

    // Legs
    paint.color = const Color(0xFFD8CEF0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(cx - 20, size.height * 0.87),
              width: 22, height: 28),
          const Radius.circular(8)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(cx + 20, size.height * 0.87),
              width: 22, height: 28),
          const Radius.circular(8)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ══════════════════════════════════════════════════════
// SUGGESTION CHIP
// ══════════════════════════════════════════════════════
class _SuggestionChip extends StatefulWidget {
  final _Suggestion suggestion;
  final VoidCallback onTap;
  const _SuggestionChip(
      {required this.suggestion, required this.onTap});
  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFFE8E4F5), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C3FC8).withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.suggestion.title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E0F5C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(widget.suggestion.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF8A84A3),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// MESSAGE BUBBLE
// ══════════════════════════════════════════════════════
class _MessageBubble extends StatefulWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});
  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(widget.message.isUser ? 0.15 : -0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy_rounded,
                      color: Colors.white, size: 14),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(context).size.width * 0.72,
                  ),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isUser ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? const Color(0xFF6C3FC8).withOpacity(0.25)
                            : const Color(0xFF6C3FC8).withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.message.text,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: isUser
                          ? Colors.white
                          : const Color(0xFF1E0F5C),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE6FF),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (AuthController.currentUserName ?? 'U')[0]
                          .toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7C5CBF),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// TYPING DOTS ANIMATION
// ══════════════════════════════════════════════════════
class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final t = (_ctrl.value - delay).clamp(0.0, 0.5) * 2;
            final opacity = math.sin(t * math.pi).clamp(0.3, 1.0);
            return Container(
              width: 7, height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF7C5CBF).withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════
// MODELS
// ══════════════════════════════════════════════════════
class _ChatSession {
  final String title;
  final List<_ChatMessage> messages;
  final DateTime date;
  const _ChatSession(
      {required this.title,
      required this.messages,
      required this.date});
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final TimeOfDay time;
  const _ChatMessage(
      {required this.text, required this.isUser, required this.time});
}

class _Suggestion {
  final String title, subtitle;
  const _Suggestion({required this.title, required this.subtitle});
}