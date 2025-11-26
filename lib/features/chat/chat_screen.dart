import 'package:flutter/material.dart';
import 'package:healthcare/core/widgets/splash_screen.dart';
import 'package:intl/intl.dart';
import 'package:healthcare/services/chat_service.dart';
import 'package:healthcare/services/socket_service.dart';

class ChatScreen extends StatefulWidget {
  final String toUserId;
  final String displayName;

  const ChatScreen({
    super.key,
    required this.toUserId,
    required this.displayName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ChatService _chatService = ChatService();
  final socket = SocketService();

  String? _chatId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  /// -------------------------------
  /// Load chat + messages
  /// -------------------------------
  Future<void> _initChat() async {
    try {
      final res = await _chatService.getUserChats();
      final chats = res["data"] as List;

      final existing = chats.firstWhere(
        (c) => List.from(c["participants"]).contains(widget.toUserId),
        orElse: () => null,
      );

      if (existing != null) {
        _chatId = existing["_id"];

        final messagesRes = await _chatService.getMessages(_chatId!);
        final messages = messagesRes["data"] as List;

        setState(() {
          _messages.addAll(
            messages.map((m) {
              return {
                "isUser": m["sender"] != widget.toUserId,
                "text": m["message"],
                "time": DateTime.parse(m["createdAt"]).toLocal(),
              };
            }),
          );
        });
      } else {
        final res = await _chatService.startChat(otherUserId: widget.toUserId);
        _chatId = res["data"]["_id"];
      }

      await _initSocketListeners();
    } catch (e) {
      print("Chat init failed: $e");
    }

    setState(() => _isLoading = false);
    _scrollToBottom();
  }

  /// -------------------------------
  /// Socket listeners
  /// -------------------------------
  Future<void> _initSocketListeners() async {
    socket.onCallEvent.listen((event) {
      final type = event["event"];
      final data = event["data"];

      if (type == SocketEvents.CHAT_MESSAGE && data["chatId"] == _chatId) {
        _handleIncomingMessage(data);
      }
    });
  }

  void _handleIncomingMessage(dynamic data) {
    if (!mounted) return;
    print(" CHAT $data");
    setState(() {
      _messages.add({
        "isUser": false,
        "text": data["text"],
        "time": DateTime.now().toLocal(),
      });
    });

    _scrollToBottom();
  }

  /// -------------------------------
  /// Send Message
  /// -------------------------------
  void _sendMessage() {
    if (_controller.text.trim().isEmpty || _chatId == null) return;

    final text = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add({"isUser": true, "text": text, "time": DateTime.now()});
    });

    socket.emit(SocketEvents.CHAT_MESSAGE, {
      "chatId": _chatId,
      "toUserId": widget.toUserId,
      "text": text,
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  String formatDateHeader(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) return "Today";
    if (messageDate == yesterday) return "Yesterday";

    return DateFormat('dd MMM yyyy').format(date);
  }

  /// -------------------------------
  /// UI
  /// -------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF01312F),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              widget.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),

      body: _isLoading
          ? const SplashScreen()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg["isUser"] as bool;
                      final time = msg["time"] as DateTime;

                      // CHECK IF NEW DAY STARTS
                      bool showDateHeader = false;

                      if (index == 0) {
                        showDateHeader = true;
                      } else {
                        final prev = _messages[index - 1]["time"] as DateTime;
                        showDateHeader =
                            prev.day != time.day ||
                            prev.month != time.month ||
                            prev.year != time.year;
                      }

                      return Column(
                        crossAxisAlignment: isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          // DATE HEADER UI
                          if (showDateHeader)
                            Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  formatDateHeader(time),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                          // MESSAGE BUBBLE
                          Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? const Color(0xFFFFF0EB)
                                    : const Color(0xFFE5F0EE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg["text"],
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ),

                          // TIME BELOW MESSAGE
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              DateFormat('hh:mm a').format(time),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Input field
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF6F2),
                    border: Border(top: BorderSide(color: Colors.black12)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Type your message...",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
