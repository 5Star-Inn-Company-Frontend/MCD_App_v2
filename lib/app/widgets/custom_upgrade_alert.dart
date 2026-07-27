import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:mcd/app/widgets/primary_app_button.dart';

class CustomUpgradeAlert extends UpgradeAlert {
  CustomUpgradeAlert({
    super.key,
    super.upgrader,
    super.barrierDismissible = false,
    super.onIgnore,
    super.onLater,
    super.onUpdate,
    super.shouldPopScope,
    super.showPrompt = true,
    super.showIgnore = true,
    super.showLater = true,
    super.showReleaseNotes = true,
    super.dialogKey,
    super.navigatorKey,
    super.child,
  });

  @override
  UpgradeAlertState createState() => CustomUpgradeAlertState();
}

class CustomUpgradeAlertState extends UpgradeAlertState {
  @override
  void showTheDialog({
    Key? key,
    required BuildContext context,
    required String? title,
    required String message,
    required String? releaseNotes,
    required bool barrierDismissible,
    required UpgraderMessages messages,
  }) {
    if (!context.mounted) return;

    widget.upgrader.saveLastAlerted();

    showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: onCanPop(),
          child: _CustomUpgradeDialog(
            title: title ?? 'Update Available',
            message: message,
            releaseNotes: releaseNotes,
            messages: messages,
            upgrader: widget.upgrader,
            state: this,
          ),
        );
      },
    );
  }
}

class _CustomUpgradeDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? releaseNotes;
  final UpgraderMessages messages;
  final Upgrader upgrader;
  final CustomUpgradeAlertState state;

  const _CustomUpgradeDialog({
    required this.title,
    required this.message,
    this.releaseNotes,
    required this.messages,
    required this.upgrader,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final isBlocked = upgrader.blocked();
    final showIgnore = isBlocked ? false : state.widget.showIgnore;
    final showLater = isBlocked ? false : state.widget.showLater;
    // final primaryColor = Theme.of(context).primaryColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 5.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              'assets/images/mcdlogo.png',
              height: 64,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            if (releaseNotes != null && releaseNotes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  messages.message(UpgraderMessage.releaseNotes) ?? 'Release Notes:',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  releaseNotes!,
                  style: const TextStyle(fontSize: 13.0, color: Colors.black87),
                ),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryAppButton(
              title: messages.message(UpgraderMessage.buttonTitleUpdate) ?? 'UPDATE NOW',
              onTap: () async {
                state.onUserUpdated(context, !isBlocked);
              },
            ),
            if (showLater || showIgnore) const SizedBox(height: 12),
            if (showLater)
              InkWell(
                onTap: () {
                  state.onUserLater(context, true);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    messages.message(UpgraderMessage.buttonTitleLater) ?? 'Maybe Later',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            if (showIgnore && !showLater)
              InkWell(
                onTap: () {
                  state.onUserIgnored(context, true);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    messages.message(UpgraderMessage.buttonTitleIgnore) ?? 'Ignore',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
