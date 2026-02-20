import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/styles/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String messageText;
  final bool isMe;
  final DateTime? timestamp;

  const MessageBubble(
      {super.key, required this.messageText, required this.isMe, this.timestamp});

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : (timestamp.hour == 0 ? 12 : timestamp.hour);
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isMe
          ? const EdgeInsets.only(right: 12, left: 40, bottom: 5, top: 8)
          : const EdgeInsets.only(right: 40, left: 12, bottom: 5, top: 8),
      child: Align(
        alignment: isMe ? Alignment.topRight : Alignment.topLeft,
        child: IntrinsicWidth(
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.primaryGreen
                  : AppColors.primaryGreen.withOpacity(0.2),
              borderRadius: isMe
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    )
                  : const BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              isMe
                  ? Text(
                      messageText,
                      style: GoogleFonts.plusJakartaSans(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,),
                    )
                  : MarkdownBody(
                      data: messageText,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.plusJakartaSans(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        strong: GoogleFonts.plusJakartaSans (
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        em: GoogleFonts.plusJakartaSans(
                          color: Colors.black,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                        code: GoogleFonts.plusJakartaSans(
                          color: Colors.black87,
                          fontSize: 13,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        listBullet: GoogleFonts.plusJakartaSans(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        h1: GoogleFonts.plusJakartaSans(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: GoogleFonts.plusJakartaSans(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: GoogleFonts.plusJakartaSans(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              if (timestamp != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _formatTime(timestamp!),
                      style: GoogleFonts.plusJakartaSans(
                        color: isMe 
                            ? AppColors.white.withOpacity(0.8)
                            : AppColors.primaryGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
