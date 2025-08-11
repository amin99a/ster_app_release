import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chat_message.dart';
import '../utils/animations.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool showAvatar;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.onReply,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppAnimations.smoothCurve,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFromCurrentUser = widget.message.isFromCurrentUser;
    final isSystem = widget.message.isSystem;

    if (isSystem) {
      return _buildSystemMessage();
    }

    return GestureDetector(
      onLongPress: _showMessageOptions,
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _scaleController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _scaleController.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _scaleController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: isFromCurrentUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isFromCurrentUser && widget.showAvatar) ...[
                _buildAvatar(),
                const SizedBox(width: 8),
              ],

              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Column(
                    crossAxisAlignment: isFromCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (!isFromCurrentUser && !widget.showAvatar)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 4),
                          child: Text(
                            widget.message.senderName,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),

                      _buildMessageContent(isFromCurrentUser),
                    ],
                  ),
                ),
              ),

              if (isFromCurrentUser && widget.showAvatar) ...[
                const SizedBox(width: 8),
                _buildAvatar(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final isFromCurrentUser = widget.message.isFromCurrentUser;

    return CircleAvatar(
      radius: 16,
      backgroundColor: isFromCurrentUser
          ? const Color(0xFF593CFB)
          : Colors.grey.shade200,
      backgroundImage: widget.message.senderAvatar != null
          ? NetworkImage(widget.message.senderAvatar!)
          : null,
      child: widget.message.senderAvatar == null
          ? isFromCurrentUser
              ? const Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.white,
                )
              : Text(
                  widget.message.senderName.isNotEmpty
                      ? widget.message.senderName[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                )
          : null,
    );
  }

  Widget _buildMessageContent(bool isFromCurrentUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: isFromCurrentUser
            ? const LinearGradient(
                colors: [Color(0xFF593CFB), Color(0xFF7C5CFB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isFromCurrentUser ? null : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isFromCurrentUser ? 16 : 4),
          bottomRight: Radius.circular(isFromCurrentUser ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message.hasReply)
            _buildReplyPreview(isFromCurrentUser),

          _buildMessageText(isFromCurrentUser),

          const SizedBox(height: 4),

          _buildMessageFooter(isFromCurrentUser),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(bool isFromCurrentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isFromCurrentUser
            ? Colors.white.withOpacity(0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: isFromCurrentUser
                  ? Colors.white.withOpacity(0.5)
                  : const Color(0xFF593CFB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message.replyToMessage?.senderName ?? 'Unknown',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isFromCurrentUser
                        ? Colors.white.withOpacity(0.8)
                        : const Color(0xFF593CFB),
                  ),
                ),
                Text(
                  widget.message.replyToMessage?.content ?? 'Message',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isFromCurrentUser
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageText(bool isFromCurrentUser) {
    return Text(
      widget.message.content,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: isFromCurrentUser ? Colors.white : Colors.black87,
        height: 1.4,
      ),
    );
  }

  Widget _buildMessageFooter(bool isFromCurrentUser) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.message.timeString,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: isFromCurrentUser
                ? Colors.white70
                : Colors.grey.shade500,
          ),
        ),

        if (isFromCurrentUser) ...[
          const SizedBox(width: 4),
          AnimatedSwitcher(
            duration: AppAnimations.fast,
            child: Icon(
              widget.message.statusIcon,
              key: ValueKey(widget.message.status),
              size: 12,
              color: widget.message.status == MessageStatus.read
                  ? Colors.white
                  : Colors.white70,
            ),
          ),
        ],

        // Edited indicator
        if (widget.message.metadata?['edited'] == true) ...[
          const SizedBox(width: 4),
          Text(
            '(edited)',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: isFromCurrentUser
                  ? Colors.white60
                  : Colors.grey.shade400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSystemMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.message.content,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showMessageOptions() {
    final isFromCurrentUser = widget.message.isFromCurrentUser;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            // Options
            _buildOption('Reply', Icons.reply, () {
              Navigator.pop(context);
              widget.onReply?.call();
            }),

            if (isFromCurrentUser) ...[
              _buildOption('Edit', Icons.edit, () {
                Navigator.pop(context);
                widget.onEdit?.call();
              }),
              _buildOption('Delete', Icons.delete, () {
                Navigator.pop(context);
                widget.onDelete?.call();
              }),
            ],

            _buildOption('Copy', Icons.copy, () {
              Navigator.pop(context);
              // TODO: Copy to clipboard
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey.shade600,
              size: 20,
            ),

            const SizedBox(width: 16),

            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}