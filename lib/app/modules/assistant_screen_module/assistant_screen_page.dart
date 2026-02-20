import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/modules/assistant_screen_module/widgets/message_bubble.dart';
import 'package:mcd/app/modules/assistant_screen_module/widgets/typing_indicator.dart';
import 'package:mcd/app/utils/bottom_navigation.dart';
import 'package:mcd/app/widgets/app_bar.dart';
import 'package:mcd/core/import/imports.dart';
import './assistant_screen_controller.dart';

class AssistantScreenPage extends GetView<AssistantScreenController> {
  const AssistantScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog(context) ?? false;
      },
      child: Scaffold(
        appBar: PaylonyAppBar(
          title: "MCD Assistant",
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: SvgPicture.asset(AppAsset.chatAssistant),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Stack(
            children: [
              Obx(() => Visibility(
                    visible: controller.chatMessages.isEmpty &&
                        !controller.isLoadingHistory,
                    child: Align(
                      alignment: Alignment.center,
                      child: TextSemiBold(
                        "Ask anything, get you answer",
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.primaryColor,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )),
              Obx(() => Visibility(
                    visible: controller.isLoadingHistory,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  )),
              Obx(() => ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.only(
                      bottom: 100), // Add padding for input field
                  itemCount: controller.chatMessages.length +
                      (controller.isThinking ? 1 : 0),
                  itemBuilder: (context, index) {
                    // If thinking, show indicator at index 0 (bottom)
                    if (controller.isThinking && index == 0) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: TypingIndicator(),
                      );
                    }

                    // Adjust index if thinking indicator is present
                    final listIndex = controller.isThinking ? index - 1 : index;
                    final message = controller.chatMessages[listIndex];
                    
                    // Check if we need to show a date header
                    bool showDateHeader = false;
                    if (listIndex < controller.chatMessages.length - 1) {
                      final nextMessage = controller.chatMessages[listIndex + 1];
                      if (message.timestamp != null && nextMessage.timestamp != null) {
                        final messageDate = DateTime(
                          message.timestamp!.year,
                          message.timestamp!.month,
                          message.timestamp!.day,
                        );
                        final nextMessageDate = DateTime(
                          nextMessage.timestamp!.year,
                          nextMessage.timestamp!.month,
                          nextMessage.timestamp!.day,
                        );
                        showDateHeader = !messageDate.isAtSameMomentAs(nextMessageDate);
                      }
                    } else {
                      // Always show date header for the last (oldest) message
                      showDateHeader = message.timestamp != null;
                    }

                    return Column(
                      children: [
                        MessageBubble(
                            messageText: message.text, 
                            isMe: !message.isAi,
                            timestamp: message.timestamp),
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              _formatDate(message.timestamp!),
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    );
                  })),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // chat limit display joined to textfield
                    Obx(() {
                      if (controller.chatLimitMax <= 0) {
                        return const SizedBox.shrink();
                      }
                      
                      final remaining = controller.chatLimitMax - controller.chatLimitUsed;
                      final usagePercentage = controller.chatLimitUsed / controller.chatLimitMax;
                      
                      // Determine colors based on usage
                      Color bgColor;
                      Color textColor;
                      
                      if (usagePercentage < 0.5) {
                        // Less than 50% used - Green
                        bgColor = AppColors.primaryColor.withOpacity(0.1);
                        textColor = AppColors.primaryColor;
                      } else if (usagePercentage < 0.8) {
                        // 50-80% used - Pale Yellow
                        bgColor = const Color(0xFFFFF9E6);
                        textColor = const Color(0xFFE6A800);
                      } else {
                        // 80%+ used - Red
                        bgColor = Colors.red.withOpacity(0.1);
                        textColor = Colors.red;
                      }
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            topRight: Radius.circular(5.0),
                          ),
                          border: const Border(
                            left: BorderSide(
                                color: AppColors.filledBorderIColor,
                                width: 1),
                            right: BorderSide(
                                color: AppColors.filledBorderIColor,
                                width: 1),
                            top: BorderSide(
                                color: AppColors.filledBorderIColor,
                                width: 1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$remaining ${remaining == 1 ? "message" : "messages"} remaining out of ${controller.chatLimitMax}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFonts.manRope,
                                color: textColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  Routes.MORE_MODULE,
                                  arguments: {'initialTab': 1},
                                );
                              },
                              child: Text(
                                'Upgrade',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: AppFonts.manRope,
                                  color: textColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    TextField(
                      controller: controller.messageController,
                      style: TextStyle(fontFamily: AppFonts.manRope),
                      decoration: InputDecoration(
                          hintText: "Type here...",
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontFamily: AppFonts.manRope),
                          filled: true,
                          suffixIcon: GestureDetector(
                            onTap: controller.addMessage,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: SvgPicture.asset(AppAsset.sendMessage),
                            ),
                          ),
                          fillColor: AppColors.filledInputColor,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: controller.chatLimitMax > 0
                                  ? const BorderRadius.only(
                                      bottomLeft: Radius.circular(5.0),
                                      bottomRight: Radius.circular(5.0),
                                    )
                                  : BorderRadius.circular(5.0),
                              borderSide: const BorderSide(
                                  color: AppColors.filledBorderIColor,
                                  width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: controller.chatLimitMax > 0
                                  ? const BorderRadius.only(
                                      bottomLeft: Radius.circular(5.0),
                                      bottomRight: Radius.circular(5.0),
                                    )
                                  : BorderRadius.circular(5.0),
                              borderSide: const BorderSide(
                                  color: AppColors.filledBorderIColor,
                                  width: 1))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavigation(selectedIndex: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Exit App',
            style: TextStyle(fontFamily: AppFonts.manRope)),
        content: const Text('Do you want to exit the app?',
            style: TextStyle(fontFamily: AppFonts.manRope)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No',
                style: TextStyle(fontFamily: AppFonts.manRope)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes',
                style: TextStyle(fontFamily: AppFonts.manRope)),
          ),
        ],
      ),
    );
  }
}
