import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';
import '../../core/services/nexus_api.dart';

class AiAssistantScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const AiAssistantScreen({super.key, required this.onNavigate});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final NexusApi _api = NexusApi();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I am the Mobawi CEO Command Assistant. Ask me anything about server uptime, billing logs, client sessions, or deployment status.',
      'isUser': false,
      'time': 'Just now',
    }
  ];

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _inputController.clear();
    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'time': 'Just now',
      });
      _isSending = true;
    });

    _scrollToBottom();

    final response = await _api.sendAiMessage(text);
    if (mounted) {
      setState(() {
        _messages.add({
          'text': response['reply'] ?? 'Failed to parse response.',
          'isUser': false,
          'time': 'Just now',
        });
        _isSending = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CO-FOUNDER AI ASSISTANT', style: theme.textTheme.displayLarge),
          const SizedBox(height: 4),
          Text('Ask queries regarding billing data, server incidents, edge proxy controls, or invoke actions.', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chat Box
                Expanded(
                  flex: 3,
                  child: NexusCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        // Messages Area
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final msg = _messages[index];
                                final isUser = msg['isUser'] as bool;
                                final text = msg['text'] as String;

                                return _buildMessageBubble(text, isUser);
                              },
                            ),
                          ),
                        ),
                        if (_isSending)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: NexusTheme.accent),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Gemini cost estimation compiler routing query...', style: TextStyle(color: NexusTheme.textMuted, fontSize: 10)),
                                ],
                              ),
                            ),
                          ),
                        const Divider(height: 1),
                        // Input Area
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _inputController,
                                  onSubmitted: _sendMessage,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                    hintText: 'Type query (e.g. "Are the servers online?" or "Get MRR statistics")...',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(fontSize: 12, color: NexusTheme.textMuted),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.send_outlined, color: theme.primaryColor),
                                onPressed: () => _sendMessage(_inputController.text),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Suggested Prompts Sidebar
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NexusCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quick Commands', style: theme.textTheme.titleLarge),
                            const SizedBox(height: 8),
                            const Text('Click any query range below to command the AI router directly.', style: TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
                            const SizedBox(height: 20),
                            _buildCommandPromptChip('Check infrastructure node health'),
                            _buildCommandPromptChip('Get active billing MRR stats'),
                            _buildCommandPromptChip('List slow queries on databases'),
                            _buildCommandPromptChip('List active operators online now'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bubbleBg = isUser
        ? theme.primaryColor
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9));

    final textColor = isUser
        ? Colors.white
        : (isDark ? Colors.white : Colors.black87);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.45,
        ),
        decoration: BoxDecoration(
          color: bubbleBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 13, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildCommandPromptChip(String prompt) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? NexusTheme.border : NexusTheme.lightBorder;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _sendMessage(prompt),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: borderColor),
        ),
        child: Text(
          prompt,
          style: TextStyle(fontSize: 11, color: theme.primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
