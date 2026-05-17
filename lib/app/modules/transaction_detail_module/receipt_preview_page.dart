import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/utils/functions.dart';
import './transaction_detail_module_controller.dart';

import './receipt_template.dart';

class ReceiptPreviewPage extends StatefulWidget {
  final ReceiptTemplate template;
  final TransactionDetailModuleController controller;

  const ReceiptPreviewPage({
    super.key,
    required this.template,
    required this.controller,
  });

  @override
  State<ReceiptPreviewPage> createState() => _ReceiptPreviewPageState();
}

class _ReceiptPreviewPageState extends State<ReceiptPreviewPage>
    with SingleTickerProviderStateMixin {
  final _receiptKey = GlobalKey();
  bool _isSaving = false;
  bool _isSharing = false;
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  ReceiptTemplate get _t => widget.template;
  TransactionDetailModuleController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6, end: 6)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  String get _templateLabel {
    switch (_t) {
      case ReceiptTemplate.receipt:
        return '';
      case ReceiptTemplate.birthday:
        return 'Birthday';
      case ReceiptTemplate.valentine:
        return 'Valentine';
      case ReceiptTemplate.wishes:
        return 'Wishes';
    }
  }

  Color get _scaffoldBg {
    switch (_t) {
      case ReceiptTemplate.receipt:
        return const Color(0xFFF2F5F2);
      case ReceiptTemplate.birthday:
        return const Color(0xFFFFF8E1);
      case ReceiptTemplate.valentine:
        return const Color(0xFFFFF0F3);
      case ReceiptTemplate.wishes:
        return const Color(0xFFF3F0FF);
    }
  }

  Color get _accent {
    switch (_t) {
      case ReceiptTemplate.receipt:
        return AppColors.primaryColor;
      case ReceiptTemplate.birthday:
        return const Color(0xFFFF6F00);
      case ReceiptTemplate.valentine:
        return const Color(0xFFE91E63);
      case ReceiptTemplate.wishes:
        return const Color(0xFF7C3AED);
    }
  }

  SystemUiOverlayStyle get _overlayStyle => SystemUiOverlayStyle.dark;

  Color _statusColor() {
    final s = _c.status.toLowerCase();
    if (s == 'successful' || s == 'success' || s == 'delivered') {
      return AppColors.primaryColor;
    }
    if (s == 'pending' || s == 'processing') return Colors.orange;
    if (s == 'reversed' || s == 'reversal') return Colors.blue;
    return Colors.red;
  }

  IconData _statusIcon() {
    final s = _c.status.toLowerCase();
    if (s == 'successful' || s == 'success' || s == 'delivered') {
      return Icons.check_circle_rounded;
    }
    if (s == 'pending' || s == 'processing') return Icons.pending_rounded;
    if (s == 'reversed' || s == 'reversal') return Icons.sync_rounded;
    return Icons.cancel_rounded;
  }

  String _statusLabel() {
    final s = _c.status.toLowerCase();
    if (s == 'successful' || s == 'success' || s == 'delivered') {
      return 'Successful';
    }
    if (s == 'pending' || s == 'processing') return 'Pending';
    if (s == 'reversed' || s == 'reversal') return 'Reversed';
    return 'Failed';
  }

  String get _amount => '₦${Functions.money(_c.amount, "").trim()}';

  Widget _row(String label, String value,
      {Color lc = Colors.black,
      Color vc = Colors.black,
      TextStyle? labelStyle,
      TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle ?? TextStyle(fontSize: 13, color: lc)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: valueStyle ??
                    TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: vc),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 2),
          ),
        ],
      ),
    );
  }

  List<Widget> _txFields({Color lc = Colors.black, Color vc = Colors.black}) {
    final type = _c.paymentType.toLowerCase();
    final List<Widget> fields = [];

    // User ID
    fields.add(_row('User ID', _c.userId, lc: lc, vc: vc));

    // Dynamic ID field (Phone Number, Meter Number, Account ID)
    if (type.contains('electricity') || type.contains('electric')) {
      fields.add(_row('Meter Number', _c.phoneNumber, lc: lc, vc: vc));
    } else if (type.contains('betting') || type.contains('bet')) {
      fields.add(_row('Account ID', _c.phoneNumber, lc: lc, vc: vc));
    } else if (type.contains('nin')) {
      fields.add(_row(
          'NIN Number', _c.ninNin != 'N/A' ? _c.ninNin : _c.phoneNumber,
          lc: lc, vc: vc));
    } else if (!type.contains('airtime_pin') &&
        !type.contains('data_pin') &&
        !type.contains('wallet') &&
        !type.contains('giveaway') &&
        !type.contains('funding') &&
        !type.contains('vcard') &&
        !type.contains('reversal') &&
        !type.contains('predictwin') &&
        !type.contains('momo') &&
        !type.contains('nin validation')) {
      fields.add(_row('Phone Number', _c.phoneNumber, lc: lc, vc: vc));
    }

    // Network / Payment Type
    if (type.contains('data') ||
        type.contains('airtime') ||
        type.contains('cable')) {
      if (_c.network.isNotEmpty) {
        fields.add(_row('Network', _c.network, lc: lc, vc: vc));
      }
    } else {
      fields.add(_row('Payment Type', _c.paymentType, lc: lc, vc: vc));
    }

    // Package Name
    if (_c.packageName != 'N/A' && _c.packageName.isNotEmpty) {
      String label = 'Package';
      if (type.contains('data')) label = 'Data Plan';
      if (type.contains('electricity')) label = 'Meter Type';
      fields.add(_row(label, _c.packageName, lc: lc, vc: vc));
    }

    // Date & Reference
    fields.add(_row('Date', _c.date, lc: lc, vc: vc));
    fields.add(_row('Reference', _c.transactionId, lc: lc, vc: vc));

    return fields;
  }

  Widget _buildReceiptTemplate() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.12),
              blurRadius: 28,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          // green top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.primaryColor2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              image: const DecorationImage(
                image: AssetImage('assets/images/receipts_bg/blue.png'),
                fit: BoxFit.cover,
                opacity: 0.15,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Image.asset(_c.image,
                    width: 56,
                    height: 56,
                    errorBuilder: (_, __, ___) => const Icon(Icons.receipt_long,
                        size: 56, color: Colors.white)),
                const SizedBox(height: 10),
                Text(_c.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(_amount,
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                _statusChip(light: true),
              ],
            ),
          ),
          // perforated edge
          _PerforatedEdge(color: const Color(0xFFF2F5F2)),
          // fields
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
            child: Column(children: _txFields()),
          ),
          _divider(),
          // footer
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text('5Star Company • MCD',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  //  BIRTHDAY
  Widget _buildBirthdayTemplate() {
    const orange = Color(0xFFFF6F00);
    const yellow = Color(0xFFFFCA28);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: yellow, width: 2),
        boxShadow: [
          BoxShadow(
              color: orange.withOpacity(0.18),
              blurRadius: 28,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          // birthday header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFFF6F00), Color(0xFFFF9100)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              image: const DecorationImage(
                image: AssetImage('assets/images/receipts_bg/orange.png'),
                fit: BoxFit.cover,
                opacity: 0.45,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  // main content
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 26, 16, 20),
                    child: Column(
                      children: [
                        Text('🎂 Happy Birthday! 🎂',
                            style: GoogleFonts.pacifico(
                                fontSize: 20, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text("Here's your payment receipt",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13)),
                        const SizedBox(height: 24),
                        Text(_c.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.5), width: 1),
                          ),
                          child: Text(_amount,
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(height: 12),
                        _statusChip(
                            bg: Colors.white.withOpacity(0.1),
                            tc: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _PerforatedEdge(color: const Color(0xFFFFF8E1)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
            child:
                Column(children: _txFields(lc: Colors.black, vc: Colors.black)),
          ),
          _divider(color: yellow.withOpacity(0.4)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🎉 ', style: TextStyle(fontSize: 14)),
                Text('5Star Company • MCD',
                    style: TextStyle(
                        color: orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                Text(' 🎉', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //  VALENTINE
  Widget _buildValentineTemplate() {
    const rose = Color(0xFFE91E63);
    const blush = Color(0xFFFCE4EC);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: rose.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: rose.withOpacity(0.18),
              blurRadius: 28,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          // valentine header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              image: const DecorationImage(
                image: AssetImage('assets/images/receipts_bg/pink.png'),
                fit: BoxFit.cover,
                opacity: 0.4,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  // scattered hearts overlay
                  const Positioned(
                      top: 10,
                      left: 10,
                      child: Text('❤️', style: TextStyle(fontSize: 24))),
                  const Positioned(
                      top: 40,
                      right: 15,
                      child: Text('💕', style: TextStyle(fontSize: 26))),
                  const Positioned(
                      bottom: 25,
                      left: 30,
                      child: Text('💖', style: TextStyle(fontSize: 22))),
                  const Positioned(
                      bottom: 60,
                      right: -5,
                      child: Text('🩷', style: TextStyle(fontSize: 28))),
                  const Positioned(
                      top: 100,
                      left: -10,
                      child: Text('🩷', style: TextStyle(fontSize: 32))),

                  // main content
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 26, 16, 22),
                    child: Column(
                      children: [
                        Text('❤️   With Love   ❤️',
                            style: GoogleFonts.greatVibes(
                                fontSize: 30, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('A heartfelt payment for you',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13)),
                        const SizedBox(
                            height:
                                28), // replaces bottom padding from HeartsRow
                        Text(_c.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(_amount,
                            style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 10),
                        _statusChip(light: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // blush band
          Container(
            color: blush,
            height: 10,
          ),
          _PerforatedEdge(color: const Color(0xFFFFF0F3)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
            child:
                Column(children: _txFields(lc: Colors.black, vc: Colors.black)),
          ),
          _divider(color: rose.withOpacity(0.2)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text('5Star Company • MCD 💕',
                style: TextStyle(
                    color: rose, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  //  WISHES
  Widget _buildWishesTemplate() {
    const purple = Color(0xFF7C3AED);
    const gold = Color(0xFFFFB300);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: purple.withOpacity(0.18),
              blurRadius: 28,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          // wishes header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              image: const DecorationImage(
                image: AssetImage('assets/images/receipts_bg/yellow.png'),
                fit: BoxFit.cover,
                opacity: 0.35,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  // scattered emojis
                  const Positioned(
                      top: 10,
                      left: 10,
                      child: Text('✨', style: TextStyle(fontSize: 24))),
                  const Positioned(
                      top: 40,
                      right: 15,
                      child: Text('⭐', style: TextStyle(fontSize: 26))),
                  const Positioned(
                      bottom: 25,
                      left: 30,
                      child: Text('🌟', style: TextStyle(fontSize: 22))),
                  const Positioned(
                      bottom: 60,
                      right: -5,
                      child: Text('🎊', style: TextStyle(fontSize: 28))),
                  const Positioned(
                      top: 100,
                      left: -10,
                      child: Text('🎉', style: TextStyle(fontSize: 32))),

                  // main content
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 26, 16, 22),
                    child: Column(
                      children: [
                        Text('✨ Congratulations! ✨',
                            style: GoogleFonts.cinzel(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: gold)),
                        const SizedBox(height: 4),
                        Text('Wishing you all the best',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13)),
                        const SizedBox(
                            height: 28), // replaces _SparkleRow wrapper gap
                        Text(_c.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: gold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: gold.withOpacity(0.6)),
                          ),
                          child: Text(_amount,
                              style: GoogleFonts.plusJakartaSans(
                                  color: gold,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(height: 12),
                        _statusChip(
                            bg: Colors.white.withOpacity(0.12),
                            tc: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _PerforatedEdge(color: const Color(0xFFF3F0FF)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
            child:
                Column(children: _txFields(lc: Colors.black, vc: Colors.black)),
          ),
          _divider(color: gold.withOpacity(0.3)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text('5Star Company • MCD 🌟',
                style: TextStyle(
                    color: purple, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _statusChip({bool light = false, Color? bg, Color? tc}) {
    final sc = _statusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color:
            bg ?? (light ? Colors.white.withOpacity(0.2) : sc.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(20),
        border: light ? Border.all(color: Colors.white.withOpacity(0.5)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(),
              color: tc ?? (light ? Colors.white : sc), size: 15),
          const SizedBox(width: 5),
          Text(_statusLabel(),
              style: TextStyle(
                  color: tc ?? (light ? Colors.white : sc),
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _divider({Color? color}) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 1,
        color: color ?? const Color(0xFFECEFF1),
      );

  Widget _buildReceipt() {
    switch (_t) {
      case ReceiptTemplate.receipt:
        return _buildReceiptTemplate();
      case ReceiptTemplate.birthday:
        return _buildBirthdayTemplate();
      case ReceiptTemplate.valentine:
        return _buildValentineTemplate();
      case ReceiptTemplate.wishes:
        return _buildWishesTemplate();
    }
  }

  Future<void> _shareReceipt() async {
    setState(() => _isSharing = true);
    try {
      final boundary = _receiptKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final tmp = await getTemporaryDirectory();
      final file =
          File('${tmp.path}/receipt_${_templateLabel.toLowerCase()}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      await Share.shareXFiles([XFile(file.path)]);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _downloadReceipt() async {
    setState(() => _isSaving = true);
    try {
      final boundary = _receiptKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      await Permission.storage.request();
      String savePath;
      if (Platform.isAndroid) {
        final dir = Directory('/storage/emulated/0/Pictures/MCD');
        if (!await dir.exists()) await dir.create(recursive: true);
        savePath =
            '${dir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png';
      } else {
        final dir = await getApplicationDocumentsDirectory();
        savePath =
            '${dir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png';
      }

      await File(savePath).writeAsBytes(bytes);

      Get.snackbar(
        'Saved',
        'Receipt saved to gallery',
        backgroundColor: _accent.withOpacity(0.1),
        colorText: _accent,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
        icon: Icon(Icons.check_circle, color: _accent),
        duration: const Duration(seconds: 3),
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not save receipt',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: AppBar(
        backgroundColor: _scaffoldBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          '$_templateLabel Receipt',
          style: const TextStyle(
              color: Colors.black87, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        systemOverlayStyle: _overlayStyle,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // animated receipt card
                AnimatedBuilder(
                  animation: _floatAnim,
                  builder: (_, child) => Transform.translate(
                      offset: Offset(0, _floatAnim.value), child: child),
                  child: RepaintBoundary(
                    key: _receiptKey,
                    child: _buildReceipt(),
                  ),
                ),
                const SizedBox(height: 40),
                // action row
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: 'Share',
                        icon: Icons.share_rounded,
                        accent: _accent,
                        loading: _isSharing,
                        onTap: _shareReceipt,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _ActionBtn(
                        label: 'Download',
                        icon: Icons.download_rounded,
                        accent: _accent,
                        loading: _isSaving,
                        onTap: _downloadReceipt,
                        outlined: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PerforatedEdge extends StatelessWidget {
  final Color color;
  const _PerforatedEdge({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: CustomPaint(painter: _PerforatedPainter(bg: color)),
    );
  }
}

class _PerforatedPainter extends CustomPainter {
  final Color bg;
  const _PerforatedPainter({required this.bg});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = bg;

    // draw dashed line
    final linePaint = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    double x = 0;
    const r = 8.0;
    const gap = 18.0;

    // hole circles at top edge
    while (x < size.width) {
      canvas.drawCircle(Offset(x + r, 0), r, bgPaint);
      x += gap;
    }

    // dashed midline
    double dx = 0;
    while (dx < size.width) {
      path.moveTo(dx, size.height / 2);
      path.lineTo(dx + 8, size.height / 2);
      dx += 14;
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_PerforatedPainter old) => old.bg != bg;
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accent;
  final bool loading;
  final bool outlined;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.loading = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : accent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent, width: 1.8),
        ),
        child: loading
            ? Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: outlined ? accent : Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: outlined ? accent : Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(label,
                      style: TextStyle(
                          color: outlined ? accent : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ],
              ),
      ),
    );
  }
}
