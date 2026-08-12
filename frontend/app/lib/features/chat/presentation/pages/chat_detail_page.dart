import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_async_view.dart';
import '../../../../shared/models/chat_model.dart';
import '../../application/chat_controller.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  final String sessionId;

  const ChatDetailPage({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  final List<ChatMessage> _optimisticMessages = [];

  final List<String> _suggestedActionChips = [
    'Bingung Mengenai Judol',
    'Menanggulangi Judol',
    'Tinjau Transaksi Anomali',
    'Buat Target Tabungan',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend([String? presetText]) async {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    if (presetText == null) {
      _textController.clear();
    }

    final userMsg = ChatMessage(
      id: 'opt-${DateTime.now().millisecondsSinceEpoch}',
      sessionId: widget.sessionId,
      sender: MessageSender.user,
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _optimisticMessages.add(userMsg);
      _isSending = true;
    });
    _scrollToBottom();

    try {
      await ref.read(chatControllerProvider.notifier).sendMessage(
            sessionId: widget.sessionId,
            content: text,
          );
      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.sessionId));
    final serverMessages = messagesAsync.valueOrNull ?? const [];

    // Clean up optimistic messages that are now confirmed in serverMessages
    _optimisticMessages.removeWhere((opt) => serverMessages.any(
        (m) => m.content == opt.content && m.sender == MessageSender.user));

    final combinedMessages = List<ChatMessage>.from(serverMessages);
    for (final opt in _optimisticMessages) {
      if (!combinedMessages.any(
          (m) => m.content == opt.content && m.sender == MessageSender.user)) {
        combinedMessages.add(opt);
      }
    }

    final isLoadingInitial = messagesAsync.isLoading && combinedMessages.isEmpty;
    final hasErrorInitial = messagesAsync.hasError && combinedMessages.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutePaths.mediation);
            }
          },
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // White Circular Robot Avatar Container
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                AppAssets.robotAi,
                errorBuilder: (ctx, err, stack) => const Icon(
                  Icons.smart_toy_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konselor AI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onSelected: (val) {
              if (val == 'clear') {
                ref
                    .read(chatControllerProvider.notifier)
                    .deleteSession(widget.sessionId);
                context.pop();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus Sesi Chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Scrollable Chat Message List
          Expanded(
            child: Builder(
              builder: (context) {
                if (isLoadingInitial) {
                  return const AppLoadingView(message: 'Memuat histori percakapan...');
                }
                if (hasErrorInitial) {
                  return AppErrorView(
                    message: messagesAsync.error.toString(),
                    onRetry: () =>
                        ref.invalidate(chatMessagesProvider(widget.sessionId)),
                  );
                }

                return ListView(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  children: [
                    // Date Divider Chip: "Hari ini"
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Hari ini',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    // Render Messages
                    ...combinedMessages.map((msg) => _buildMessageBubble(msg)),

                    // Assistant Loading Indicator Bubble
                    if (_isSending) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Color(0xFFD97706),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Konselor AI sedang mengetik...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF92400E),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),

          // Suggested Action Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _suggestedActionChips.map((chip) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: const StadiumBorder(),
                    label: Text(
                      chip,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    onPressed: () => _handleSend(chip),
                  ),
                );
              }).toList(),
            ),
          ),

          // Bottom Message Input Bar matching Screenshot 1
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Input TextField Pill Container
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left '+' attachment icon
                        const Icon(
                          Icons.add_rounded,
                          color: Color(0xFF9CA3AF),
                          size: 22,
                        ),
                        const SizedBox(width: 8),

                        // Text Input (Multiline Auto-expanding)
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 120,
                            ),
                            child: TextField(
                              controller: _textController,
                              minLines: 1,
                              maxLines: 5,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF111827),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Ketik pesan...',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9CA3AF),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ),

                        // Camera Icon 📷
                        const Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Circular Green Send/Mic Button
                GestureDetector(
                  onTap: () => _handleSend(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.sender == MessageSender.user;
    final timeStr = DateFormat('HH:mm').format(msg.timestamp);

    if (isUser) {
      // User Message Bubble (Bright Green #10B981, White Text)
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14, left: 48),
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A10B981),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeStr,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      // Assistant Message Bubble (Soft Cream #FFFBEB, Dark Text)
      final isSafetyAlert = msg.safetyLevel == SafetyLevel.urgentSafety;

      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14, right: 48),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSafetyAlert
                ? const Color(0xFFFEF2F2)
                : const Color(0xFFFFFBEB),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: isSafetyAlert
                ? Border.all(color: const Color(0xFFFCA5A5))
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSafetyAlert) ...[
                const Row(
                  children: [
                    Icon(Icons.shield_rounded,
                        color: Color(0xFFDC2626), size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Peringatan Keselamatan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Text(
                msg.content,
                style: TextStyle(
                  fontSize: 14,
                  color: isSafetyAlert
                      ? const Color(0xFF7F1D1D)
                      : const Color(0xFF111827),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              if (isSafetyAlert) ...[
                const SizedBox(height: 6),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push(AppRoutePaths.professionals);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 0,
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Bicara dengan Ahli'),
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSafetyAlert
                        ? const Color(0xFF991B1B)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
