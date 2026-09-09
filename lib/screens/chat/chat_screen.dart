import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../theme.dart';
import '../../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final List<String> _suggestions = [
    '🌱 Berapa kelembapan tanah yang ideal?',
    '💧 Tips jadwal penyiraman saat musim hujan',
    '🐛 Cara membasmi hama kutu daun alami',
    '☀️ Berapa suhu optimal untuk pertumbuhan tanaman?',
  ];

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
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

  Future<void> _send([String? customText]) async {
    final text = (customText ?? _textCtrl.text).trim();
    if (text.isEmpty) return;
    if (customText == null) _textCtrl.clear();
    await context.read<ChatProvider>().sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: VerdaticaTheme.bgLight,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: VerdaticaTheme.headerGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF22C55E), Color(0xFF059669)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(Icons.eco_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Verdatica AI Bot',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            'Konsultan Cerdas Perawatan Tanaman',
                            style: TextStyle(
                              color: Color(0xFFBBF7D0),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Consumer<ChatProvider>(
                      builder: (_, chat, __) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: chat.isTyping
                              ? Colors.amber.withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: chat.isTyping
                                    ? Colors.amber
                                    : const Color(0xFF4ADE80),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              chat.isTyping ? 'Mengetik...' : 'Online',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Messages
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chat, _) {
                _scrollToBottom();
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount:
                      chat.messages.length + (chat.isTyping ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == chat.messages.length && chat.isTyping) {
                      return const TypingIndicator();
                    }
                    return ChatBubble(message: chat.messages[i]);
                  },
                );
              },
            ),
          ),

          // Quick Suggestion Chips (Horizontal Scroll)
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final text = _suggestions[i];
                return ActionChip(
                  label: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: VerdaticaTheme.primaryDark,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: VerdaticaTheme.cardBorder, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onPressed: () => _send(text),
                );
              },
            ),
          ),

          // Input Bar
          Consumer<ChatProvider>(
            builder: (context, chat, _) {
              return Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  10 + MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(
                    top: BorderSide(color: VerdaticaTheme.cardBorderSubtle, width: 1.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F3E26).withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textCtrl,
                        enabled: !chat.isTyping,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Tulis pertanyaan seputar tanaman...',
                          hintStyle: const TextStyle(
                            color: VerdaticaTheme.textMuted,
                            fontSize: 13.5,
                          ),
                          filled: true,
                          fillColor: VerdaticaTheme.bgLight,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: VerdaticaTheme.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: VerdaticaTheme.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: VerdaticaTheme.primary,
                              width: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: chat.isTyping ? null : () => _send(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: chat.isTyping
                              ? const LinearGradient(
                                  colors: [Color(0xFF9CA3AF), Color(0xFF9CA3AF)],
                                )
                              : VerdaticaTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: chat.isTyping
                              ? []
                              : [
                                  BoxShadow(
                                    color: VerdaticaTheme.primary.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Icon(
                          chat.isTyping
                              ? Icons.hourglass_empty_rounded
                              : Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
