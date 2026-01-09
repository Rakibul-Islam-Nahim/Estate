import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> property;
  final String userName;
  final String userEmail;

  const ChatPage({
    super.key,
    required this.property,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _loading = false;
  List<dynamic> messages = [];
  bool _introSent = false;

  int? get _propertyId {
    final id = widget.property['id'];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _propertySummaryMessage() {
    final title = widget.property['title'] ?? 'this property';
    final location = widget.property['location'] ?? '';
    final area = widget.property['total_area']?.toString() ?? '';
    final units = widget.property['total_units']?.toString() ?? '';
    final beds = widget.property['bedrooms']?.toString() ?? '';
    final baths = widget.property['bathrooms']?.toString() ?? '';
    final price = widget.property['price']?.toString() ?? '';
    final description = widget.property['description'] ?? '';
    return '''$title
Location: $location
Area: $area sq ft
Units: $units
Bedrooms: $beds
Bathrooms: $baths
Price: ৳$price
Description: $description
''';
  }

  Future<void> _loadMessages() async {
    final pid = _propertyId;
    if (pid == null) return;
    try {
      final resp = await http.get(
        Uri.parse(
          'http://127.0.0.1:8000/api/chat/$pid?user_email=${Uri.encodeComponent(widget.userEmail)}',
        ),
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        setState(() {
          messages = data['messages'] ?? [];
        });
        if (messages.isEmpty && !_introSent) {
          _introSent = true;
          _sendMessage(prefilled: true, text: _propertySummaryMessage());
        }
      }
    } catch (_) {}
  }

  Future<void> _sendMessage({bool prefilled = false, String? text}) async {
    final pid = _propertyId;
    if (pid == null) return;
    final msgText = (text ?? _messageController.text).trim();
    if (msgText.isEmpty) return;

    setState(() => _loading = true);
    try {
      final resp = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/chat/$pid'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_email': widget.userEmail, 'message': msgText}),
      );
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final data = json.decode(resp.body);
        setState(() {
          messages = data['messages'] ?? [];
          if (!prefilled) _messageController.clear();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final owner = widget.property['owner'] ?? {};
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5E5E5),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              owner['name'] ?? 'Property Seller',
              style: const TextStyle(color: Colors.black87),
            ),
            Text(
              widget.property['title'] ?? '',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFE5E5E5),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text('No messages yet. Start the conversation!'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMine =
                          (msg['sender_email'] ?? '')
                              .toString()
                              .toLowerCase() ==
                          widget.userEmail.toLowerCase();
                      return Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMine
                                ? const Color(0xFF32CD32).withOpacity(0.85)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['sender'] ?? 'User',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isMine ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg['message'] ?? '',
                                style: TextStyle(
                                  color: isMine ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (msg['timestamp'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    msg['timestamp'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMine
                                          ? Colors.white70
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText:
                            'Type a message... (owner is bot, only you send)',
                        fillColor: const Color(0xFFDCDCDC),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF32CD32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
