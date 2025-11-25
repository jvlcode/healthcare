import 'package:flutter/material.dart';
import 'package:healthcare/services/socket_service.dart'; // make sure path is correct

class ChatScreen extends StatefulWidget {
  final String toId;
  final String displayName;
  const ChatScreen({super.key, required this.toId, required this.displayName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  final socket = SocketService();

  @override
  void initState() {
    super.initState();
    _initSocketListeners();
  }

  Future<void> _initSocketListeners() async {
    await socket.init();

    socket.onCallEvent.listen((event) {
      final type = event["event"];
      final data = event["data"];

      if (type == SocketEvents.CHAT_MESSAGE) {
        _handleMessages(data);
      }
    });
  }

  void _handleMessages(data) {
    if (!mounted) return;

    setState(() {
      _messages.add({"isUser": false, "text": data["text"]});
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    String text = _controller.text.trim();

    // Push to UI immediately
    setState(() {
      _messages.add({"isUser": true, "text": text});
    });

    // Emit to server
    socket.emit(SocketEvents.CHAT_MESSAGE, {
      "text": text,
      "to": widget.toId,
      "timestamp": DateTime.now().toIso8601String(),
      // Add user / appointment / receiverId as needed
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF01312F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 10),
            Text(
              widget.displayName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["isUser"] as bool;

                return Align(
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
                );
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF6F2),
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Column(
              children: [
                TextField(
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
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
}
