import 'package:mcd/core/import/imports.dart';

class EditStoreProfileDialog extends StatelessWidget {
  const EditStoreProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                const Expanded(
                  child: Text(
                    'Edit Store Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: AppFonts.manRope,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close, color: Colors.black54, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Update how customers see your store on WhatsApp.',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontFamily: AppFonts.manRope,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Store name',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    fontFamily: AppFonts.manRope,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              maxLength: 40,
              style: const TextStyle(
                fontFamily: AppFonts.manRope,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: "John's Quick Bills",
                hintStyle: const TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                  fontFamily: AppFonts.manRope,
                ),
                counterText: '18/40',
                counterStyle: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontFamily: AppFonts.manRope,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.filledBorderIColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.filledBorderIColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Welcome message',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                fontFamily: AppFonts.manRope,))
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              maxLength: 140,
              maxLines: 4,
              style: const TextStyle(
                fontFamily: AppFonts.manRope,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Cheapest airtime & data 24/7. Tap below to start.',
                hintStyle: const TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                  fontFamily: AppFonts.manRope,
                ),
                counterText: '49/140',
                counterStyle: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontFamily: AppFonts.manRope,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.filledBorderIColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.filledBorderIColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: AppFonts.manRope,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.filledBorderIColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: AppFonts.manRope,
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
